From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 doing more work than napi weight
Date: Tue, 22 Jan 2013 00:42:05 +0100
Message-ID: <20130121234205.GA12449@electric-eye.fr.zoreil.com>
References: <20130121171241.2af52e12@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57578 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751541Ab3AVALL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 19:11:11 -0500
Content-Disposition: inline
In-Reply-To: <20130121171241.2af52e12@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Teras <timo.teras@iki.fi> :
[...]
> Or just delete the whole block as obsolete. 'git log' says the problem
> should have gone away by always using hardware Rx VLAN. See commit
> 05af214 "r8169: fix Ethernet Hangup for RTL8110SC rev d".

Yes, this stuff looks really strange.

Turning the whole "(desc->opts2 & cpu_to_le32(0xfffe000)) && ... " test
as a WARN_ON_ONCE in the RxRES branch seems a good trade-off from a
coward's viewpoint.

-- 
Ueimor
