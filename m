From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 24rc8: unregister_netdevice: waiting for ... to become free.
Date: Thu, 1 May 2008 22:59:48 -0700
Message-ID: <20080501225948.f351eab9.akpm@linux-foundation.org>
References: <004701c8abf4$4cefe820$6400a8c0@bui.materna.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Soeren Sonnenburg <kernel@nn7.de>
To: "Roland" <devzero@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45417 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752704AbYEBF7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 01:59:53 -0400
In-Reply-To: <004701c8abf4$4cefe820$6400a8c0@bui.materna.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2 May 2008 03:26:28 +0200 "Roland" <devzero@web.de> wrote:

> i`m also seeing this one, but with pcnet32 - "modprobe -r pcnet32" never 
> returns and
> 
> "unregister_netdevice: waiting for eth0 to become free. Usage count = 1"
> 
> being printed over and over again
> 
> lsmod |grep pcnet32 shows
> 
> pcnet32            35828    0
> mii                      9344    1    pcnet32
> 
> i see stale ssh connection on port 22 and sshd for that session remains 
> unkillable process.
> 

here a bug

> 
> 
> List:       linux-kernel
> Subject:    Re: 24rc8: unregister_netdevice: waiting for ... to become free.
> From:       Soeren Sonnenburg <kernel () nn7 ! de>
> Date:       2008-01-29 8:59:10
> Message-ID: 1201597150.4973.10.camel () localhost
> [Download message RAW]
> 
> On Tue, 2008-01-22 at 22:44 -0800, David Miller wrote:
> > From: Soeren Sonnenburg <kernel@nn7.de>
> > Date: Wed, 23 Jan 2008 07:42:21 +0100
> >
> > > Dear all,
> > >
> > > since some 2.6.24rc version I suddenly experience such messages on
> > > console when trying to shutdown a vpn connection:
> > >
> > > unregister_netdevice: waiting for tun0 to become free. Usage count = 1
> > >
> > > or when removing an usb wlan dongle (although it was ifconfig wlan0
> > > down'd before)
> >
> > Current GIT already has a fix for this, attached below:
> 
> hmmhhh, I am still seeing this problem on 2.6.24 with at least with the
> madwifi driver...
> 
> Soeren

there a bug.


Let's cc netdev@vger.kernel.org - linux-net is dead, afaik.

Thanks for reporting all these bugs but please do take much mure care over
the cc's.  Be sure to cc every party who was cc'ed on the email to which
you're replying.  I restored Soeren.

