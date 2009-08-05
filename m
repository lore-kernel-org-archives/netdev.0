From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: some veth related issues
Date: Wed, 05 Aug 2009 07:40:04 +0300
Message-ID: <4A790D24.9000008@voltaire.com>
References: <Pine.LNX.4.64.0908041650560.13803@zuben.voltaire.com> <4A785824.2030500@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:58835 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753076AbZHEEkM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2009 00:40:12 -0400
In-Reply-To: <4A785824.2030500@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> Try setting clone to 0. Might be that sending cloned pkts over veth is 
> a bad idea.

okay, thanks, this fixed the problem, however it seems there's some 
performance loss, with cloning I saw numbers of 500K packets-per-second 
and above where without cloning I get about 400K PPS.

Or.

