From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Linux 2.6.22: Leak r=1 1
Date: Wed, 18 Jul 2007 12:16:56 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0707181205550.5653@kivilampi-30.cs.helsinki.fi>
References: <20070711174030.tjmxpxtfsn4twgk2@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linux Networking Mailing List <netdev@vger.kernel.org>,
	Pasi Sarolahti <pasi.sarolahti@nokia.com>
To: Sami Farin <safari-kernel@safari.iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57212 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762326AbXGRJQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 05:16:58 -0400
In-Reply-To: <20070711174030.tjmxpxtfsn4twgk2@m.safari.iki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Jul 2007, Sami Farin wrote:

> That's right, so descriptive is the new Linux kernel 2.6.22.
> 
> Linux safari.finland.fbi 2.6.22-cfs-v19 #3 SMP Tue Jul 10 00:22:25 EEST 2007 i686 i686 i386 GNU/Linux
> 
> [root@safari /proc/sys/net/ipv4]# grep . *

...snip...

> tcp_frto:1

...This is fully unrelated to the issue but I'm a bit curious who enabled 
frto on your machine (since it's disabled by default), did you do it by 
yourself or the distribution perhaps?

This is interesting because frto to be useful in large scale, sender must 
have it enabled and therefore it's usually not under control of the host 
that is attached to the wireless access link. ...In case some 
distribution (yours) is already enabling it, the deployment is somewhat 
proceeding already :-)... ...And we also get incremental testing of the 
code too...

-- 
 i.
