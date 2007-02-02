From: Thomas Glanzmann <thomas@glanzmann.de>
Subject: Re: sky2 hangs
Date: Fri, 2 Feb 2007 07:31:04 +0100
Message-ID: <20070202063104.GA13130@cip.informatik.uni-erlangen.de>
References: <20070201185532.GL13130@cip.informatik.uni-erlangen.de> <42007.80.98.159.250.1170369983.squirrel@www.hunhost.com> <20070201145815.199bfe1a@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fagyal Csongor <concept@conceptonline.hu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1423140AbXBBGbI@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070201145815.199bfe1a@freekitty>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Stephen,

> I can reproduce the problem now (on mac mini). Interestingly it seems
> to whack the whole ethernet switch when it happens.

wow. I have Linksys wrt54g has 'ethernet switch' and my Snom 320 VoIP
phone still works when the mini network card goes down. On the other
side the wrt54g isn't exactly a switch but more like a bunch of network
cards which use the linux bridging code IIRC.

> If you do:
> 	ethtool -r eth0
> it cause a PHY reset (renegotiation) and clears the problem.

But this isn't related to my problen (on mac mini), is it?

        Thomas
