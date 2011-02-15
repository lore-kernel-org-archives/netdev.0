From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 3x59x WOL and CONFIG_SUSPEND
Date: Tue, 15 Feb 2011 21:36:16 +0100
Message-ID: <201102152136.16879.rjw@sisk.pl>
References: <4D5A85DB.7070309@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
To: Markku Pesonen <tourula@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:48694 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756037Ab1BOUgi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Feb 2011 15:36:38 -0500
In-Reply-To: <4D5A85DB.7070309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, February 15, 2011, Markku Pesonen wrote:
> Hi,
> 
> Since commit 074037ec79bea73edf1b1ec72fef1010e83e3cc5
> (PM / Wakeup: Introduce wakeup source objects and event statistics (v3)),
> Wake-On-Lan on my 3c905C has not worked unless I enable CONFIG_SUSPEND.
> The driver says "0000:00:0b.0: WOL not supported."
> 
> Enabling CONFIG_SUSPEND makes Wake-On-Lan work on 2.6.37 while 2.6.36
> works just fine without it. Is this a regression or intended behavior?

It is indended.  CONFIG_PM_SLEEP is necessary for wakeup to work (as it should
have been before).

Thanks,
Rafael
