From: William Thompson <wt@electro-mechanical.com>
Subject: Re: Network problem with bridge and virtualbox
Date: Fri, 30 Sep 2011 10:36:03 -0400
Message-ID: <20110930143603.GJ19871@electro-mechanical.com>
References: <20110929124941.GA16567@electro-mechanical.com>
 <4E84E9A7.4080008@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Nicolas de Peslo?an <nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.electro-mechanical.com ([216.184.71.30]:34178 "EHLO
	mail.electro-mechanical.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751120Ab1I3OgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 10:36:05 -0400
Content-Disposition: inline
In-Reply-To: <4E84E9A7.4080008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 29, 2011 at 11:56:55PM +0200, Nicolas de Peslo?an wrote:
> Le 29/09/2011 14:49, William Thompson a ?crit :
> >Please keep me in the CC as I am not subscribed.
> >
> >I'm using a 64-bit kernel 3.0.0 and virtualbox 4.1.2.
> >
> >My problem is that I cannot ping the host from a virtual machine.
> >
> >My bridge is configured as follows:
> ># brctl addbr br0
> ># brctl setfd br0 0
> ># brctl stp br0 off
> ># ifconfig br0 10.2.3.1 netmask 255.255.255.0
> >
> >In the virtual machine, it is set to use br0 as it's interface (bridge mode)
> >and it's IP is 10.2.3.10.
> 
> Why do you use bridge with VirtualBox?
> 
> VirtualBox provide several network modes, which remove the need for bridge on the host.
> 
> One of Bridged Network mode (using eth0), Internal Networking mode
> or Host-only Networking mode may suit your need well, without having
> to use a bridge.

I originally set this up as a hostonly (and routed) network.  The bridge has
no other interfaces added to it.  I know virtualbox has hostonly builtin, but
I did not want to use it's limited DHCP server and this was the only solution
I came up with at the time.  Due to the way the vboxnet interfaces are
dynamically created, I didn't have a way at the time to start programs on
that interface when it came up.
