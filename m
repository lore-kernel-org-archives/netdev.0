From: Michal Hocko <mhocko@suse.cz>
Subject: Re: iwl3945: regression - unregister_netdevice: waiting for wlan0
 to become free. Usage count = 1
Date: Mon, 22 Nov 2010 13:46:10 +0100
Message-ID: <20101122124610.GA3944@tiehlicka.suse.cz>
References: <20101122104341.GA3897@tiehlicka.suse.cz>
 <1290424776.2811.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-wireless@vger.kernel.org,
	Reinette Chatre <reinette.chatre@intel.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:41434 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755427Ab0KVMqN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Nov 2010 07:46:13 -0500
Content-Disposition: inline
In-Reply-To: <1290424776.2811.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon 22-11-10 12:19:36, Eric Dumazet wrote:
> Le lundi 22 novembre 2010 ?? 11:43 +0100, Michal Hocko a ??crit :
> > Hi,
> > I am experiencing iwl3945 driver reference counting problem with the current
> > 2.6.37-rc2 kernel release. 
> > 
> > The problem can be easily reproduced by associating to an AP (I have
> > tried only wep and wpa based auth) and then rmmod iw3945 which gets
> > stuck in unregister_netdevice (in the endless loop as there is no way -
> > I guess - to decrease the reference count to 0) spitting the following
> > message:
> > 
> > unregister_netdevice: waiting for wlan0 to become free. Usage count = 1
> > 
[...]
> 
> 
> Oh well, it seems David put the fix in net-next-2.6 instead of net-2.6
> 
> Please try :
> 
> http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=9d82ca98f71fd686ef2f3017c5e3e6a4871b6e46

Yes, the patch really fixes the issue. Thanks a lot!
Btw. I have checked -rc3 which doesn't conttain the fix as well.

> 
> Thanks
> 
> 

-- 
Michal Hocko
L3 team 
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic
