From: Peter Missel <peter.missel@onlinehome.de>
Subject: Re: r8169 2.2LK: Low link speed after suspend
Date: Sun, 8 Jul 2007 01:02:03 +0200
Message-ID: <200707080102.03421.peter.missel@onlinehome.de>
References: <200704162241.31729.peter.missel@onlinehome.de> <200707032000.52243.peter.missel@onlinehome.de> <200707072310.28160.peter.missel@onlinehome.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jens Stroebel <drifter@bcsoft.de>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.183]:56121 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752404AbXGGXCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2007 19:02:08 -0400
In-Reply-To: <200707072310.28160.peter.missel@onlinehome.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi again Francois!

2.6.22-rc7 does suspend-to-disk again ... and the bad news is, the reported 
problem (link speed 100 not 1000 after resume from suspend-to-disk) is still 
there when using 2.6.22-rc7 with your -rc6 driver patch.

The symptoms are the same as in 2.6.18 with unpatched r8169.

ifdown eth2
ifup eth2

does not help, but 

ifdown eth2
rmmod r8169
modprobe r8169
ifup eth2

does.

Now, exacty what do you want me to do with the mii-tool again? Please advise.

regards,
Peter
