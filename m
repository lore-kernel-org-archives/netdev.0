From: Milan Kocian <milon@wq.cz>
Subject: Re: WARNING: at net/sched/sch_generic.c:219
Date: Wed, 5 Nov 2008 10:00:34 +0100
Message-ID: <20081105090033.GB18121@ntm.vs.lam.cz>
References: <20081103092609.GA8659@ntm.vs.lam.cz> <F169D4F5E1F1974DBFAFABF47F60C10A0E873C1B@orsmsx507.amr.corp.intel.com> <20081104093923.GA11658@ntm.vs.lam.cz> <F169D4F5E1F1974DBFAFABF47F60C10A0E874224@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srw1.wq.cz ([212.71.155.176]:51690 "EHLO srw1.wq.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750812AbYKEJAk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 04:00:40 -0500
Content-Disposition: inline
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10A0E874224@orsmsx507.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 04, 2008 at 09:36:51AM -0800, Brandeburg, Jesse wrote:
> Milan Kocian wrote:
> > Thanks for answer.
> > Its selfcompiled 64bit kernel. Intel CPU QuadCore. SuperMicro
> > mainboard. 2GB RAM, Debian unstable distro.
> 
> Ah, another occurrence of our good (well not so good) friend the
> supermicro with 82573E/L.

:-)
> 
> > 0d:00.0 Ethernet controller: Intel Corporation 82573E Gigabit
> > 0e:00.0 Ethernet controller: Intel Corporation 82573L Gigabit
> 
> Please run the attached script on both of these ports (this adapter is
> one reason we have the write eeprom routines in our drivers) and let us
> know the results.
> 
> It is highly likely that there is a known issue with the eeprom (created
> from an early version of our reference eeprom) configuring the hardware
> incorrectly, which causes tx hangs.
> 
> Jesse

Many thanks.

Here is the output:

srw1:~# ./fixeep eth1
eth1: is a "82573L Gigabit Ethernet Controller"
This fixup is applicable to your hardware
Your eeprom is up to date, no changes were made
srw1:~# ./fixeep eth0
eth0: is a "82573E Gigabit Ethernet Controller"
This fixup is applicable to your hardware
executing command: ethtool -E eth0 magic 0x108c8086 offset 0x1e value 0xdf

If will be any problem I will report it.
If I understand correctly, it is fixed forever.  Or must I run it after every
reboot ?

Regards,

-- 
Milan Kocian
