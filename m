From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: iproute2 compile and linking errors on Fedora 19
Date: Tue, 31 Oct 2017 12:25:15 -0700
Message-ID: <1509477915.3828.41.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAM_iQpV07bZscuS5g6nZJ1Ko_RYVv7QyxVtga_Ky5EnbxXhCug@mail.gmail.com>
         <CAM_iQpWAvurJb3-AnUWSAGxOEQ_eKp7basJ0qYmhM8VPVg-iqQ@mail.gmail.com>
         <1509476381.3828.40.camel@edumazet-glaptop3.roam.corp.google.com>
         <854lqff7q9.fsf@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:46820 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932641AbdJaTZR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 15:25:17 -0400
Received: by mail-pf0-f175.google.com with SMTP id p87so53237pfj.3
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 12:25:17 -0700 (PDT)
In-Reply-To: <854lqff7q9.fsf@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-31 at 15:16 -0400, Roman Mashak wrote:
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> 
> 
> [...]
> 
> >     CC       iplink_xstats.o
> >     CC       ipseg6.o
> >     LINK     ip
> > xfrm_state.o: In function `xfrm_state_modify.constprop.3':
> > xfrm_state.c:(.text+0x2458): undefined reference to `strlcpy'
> > ipnetns.o: In function `netns_identify_pid':
> > ipnetns.c:(.text+0x12e0): undefined reference to `strlcpy'
> > ipxfrm.o: In function `xfrm_state_info_print':
> > ipxfrm.c:(.text+0x1c3b): undefined reference to `strlcat'
> > ipxfrm.c:(.text+0x1c4d): undefined reference to `strlcat'
> > ipxfrm.c:(.text+0x215f): undefined reference to `strlcat'
> > ipxfrm.o: In function `xfrm_policy_info_print':
> > ipxfrm.c:(.text+0x2299): undefined reference to `strlcat'
> > ipxfrm.c:(.text+0x22ab): undefined reference to `strlcat'
> > iproute_lwtunnel.o: In function `parse_encap_seg6':
> > iproute_lwtunnel.c:(.text+0xa8f): undefined reference to `strlcpy'
> > ipvrf.o: In function `vrf_switch':
> > ipvrf.c:(.text+0x87d): undefined reference to `strlcpy'
> > ipvrf.o: In function `vrf_identify.constprop.2':
> > ipvrf.c:(.text+0xe4d): undefined reference to `strlcpy'
> > ../lib/libutil.a(bpf.o): In function `bpf_find_mntpt.constprop.10':
> > bpf.c:(.text+0x766): undefined reference to `strlcpy'
> > ../lib/libutil.a(bpf.o): In function `bpf_get_work_dir':
> > bpf.c:(.text+0xb07): undefined reference to `strlcpy'
> > ../lib/libutil.a(fs.o):fs.c:(.text+0x44f): more undefined references to
> > `strlcpy' follow
> > collect2: error: ld returned 1 exit status
> > make[1]: *** [ip] Error 1
> > make[1]: Leaving directory `/usr/src/iproute2/ip'
> > make: *** [all] Error 2
> 
> Latest iproute2 has config.mk instead of Config, where a new kludge
> -DNEED_STRLCPY has been added.

Oh right, I only was missing a ./configure run to generate things
properly.
