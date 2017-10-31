From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: iproute2 compile and linking errors on Fedora 19
Date: Tue, 31 Oct 2017 22:06:31 +0100
Message-ID: <20171031220631.2297cdf8@shemminger-XPS-13-9360>
References: <CAM_iQpV07bZscuS5g6nZJ1Ko_RYVv7QyxVtga_Ky5EnbxXhCug@mail.gmail.com>
        <CAM_iQpWAvurJb3-AnUWSAGxOEQ_eKp7basJ0qYmhM8VPVg-iqQ@mail.gmail.com>
        <1509476381.3828.40.camel@edumazet-glaptop3.roam.corp.google.com>
        <854lqff7q9.fsf@mojatatu.com>
        <1509477915.3828.41.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Roman Mashak <mrv@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Phil Sutter <phil@nwl.cc>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:52388 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752237AbdJaVG6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 17:06:58 -0400
Received: by mail-lf0-f48.google.com with SMTP id b190so349964lfg.9
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 14:06:57 -0700 (PDT)
In-Reply-To: <1509477915.3828.41.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Oct 2017 12:25:15 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Tue, 2017-10-31 at 15:16 -0400, Roman Mashak wrote:
> > Eric Dumazet <eric.dumazet@gmail.com> writes:
> > 
> > 
> > [...]
> >   
> > >     CC       iplink_xstats.o
> > >     CC       ipseg6.o
> > >     LINK     ip
> > > xfrm_state.o: In function `xfrm_state_modify.constprop.3':
> > > xfrm_state.c:(.text+0x2458): undefined reference to `strlcpy'
> > > ipnetns.o: In function `netns_identify_pid':
> > > ipnetns.c:(.text+0x12e0): undefined reference to `strlcpy'
> > > ipxfrm.o: In function `xfrm_state_info_print':
> > > ipxfrm.c:(.text+0x1c3b): undefined reference to `strlcat'
> > > ipxfrm.c:(.text+0x1c4d): undefined reference to `strlcat'
> > > ipxfrm.c:(.text+0x215f): undefined reference to `strlcat'
> > > ipxfrm.o: In function `xfrm_policy_info_print':
> > > ipxfrm.c:(.text+0x2299): undefined reference to `strlcat'
> > > ipxfrm.c:(.text+0x22ab): undefined reference to `strlcat'
> > > iproute_lwtunnel.o: In function `parse_encap_seg6':
> > > iproute_lwtunnel.c:(.text+0xa8f): undefined reference to `strlcpy'
> > > ipvrf.o: In function `vrf_switch':
> > > ipvrf.c:(.text+0x87d): undefined reference to `strlcpy'
> > > ipvrf.o: In function `vrf_identify.constprop.2':
> > > ipvrf.c:(.text+0xe4d): undefined reference to `strlcpy'
> > > ../lib/libutil.a(bpf.o): In function `bpf_find_mntpt.constprop.10':
> > > bpf.c:(.text+0x766): undefined reference to `strlcpy'
> > > ../lib/libutil.a(bpf.o): In function `bpf_get_work_dir':
> > > bpf.c:(.text+0xb07): undefined reference to `strlcpy'
> > > ../lib/libutil.a(fs.o):fs.c:(.text+0x44f): more undefined references to
> > > `strlcpy' follow
> > > collect2: error: ld returned 1 exit status
> > > make[1]: *** [ip] Error 1
> > > make[1]: Leaving directory `/usr/src/iproute2/ip'
> > > make: *** [all] Error 2  
> > 
> > Latest iproute2 has config.mk instead of Config, where a new kludge
> > -DNEED_STRLCPY has been added.  
> 
> Oh right, I only was missing a ./configure run to generate things
> properly.
> 
> 
> 
> 
> 

If you do a
	$ make distclean
then
	$ make

It should take care of it.
