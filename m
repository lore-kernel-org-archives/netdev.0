From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Fix WoL on RTL8168d/8111d.
Date: Tue, 30 Oct 2012 00:01:39 +0100
Message-ID: <20121029230139.GA17476@electric-eye.fr.zoreil.com>
References: <1351392414-32219-1-git-send-email-kibi@debian.org>
 <20121028230523.GA26778@electric-eye.fr.zoreil.com>
 <20121029002140.GK6195@mraw.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Cyril Brulebois <kibi@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:37993 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844Ab2J2XE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 19:04:27 -0400
Received: from violet.fr.zoreil.com (localhost [127.0.0.1])
	by violet.fr.zoreil.com (8.13.8/8.13.8) with ESMTP id q9TMgjqb026420
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2012 23:42:45 +0100
Received: (from romieu@localhost)
	by violet.fr.zoreil.com (8.13.8/8.13.8/Submit) id q9TMgjAp026419
	for netdev@vger.kernel.org; Mon, 29 Oct 2012 23:42:45 +0100
Content-Disposition: inline
In-Reply-To: <20121029002140.GK6195@mraw.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cyril Brulebois <kibi@debian.org> :
[...]
> Thanks. Should I re-send with that as reference, or will you amend the
> patch once you're done with your testing?

It would be nice to resend, directly to netdev and davem.

Shutdown Wol behaved as expected with 3.7-rc3 for both cards: unicast WoL
failed without the patch while broadcast WoL worked. Unicast and broadcast
worked after the patch.

-- 
Ueimor
