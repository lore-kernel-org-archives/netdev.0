From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: iproute2 compile and linking errors on Fedora 19
Date: Tue, 31 Oct 2017 15:16:46 -0400
Message-ID: <854lqff7q9.fsf@mojatatu.com>
References: <CAM_iQpV07bZscuS5g6nZJ1Ko_RYVv7QyxVtga_Ky5EnbxXhCug@mail.gmail.com>
        <CAM_iQpWAvurJb3-AnUWSAGxOEQ_eKp7basJ0qYmhM8VPVg-iqQ@mail.gmail.com>
        <1509476381.3828.40.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cong Wang <xiyou.wangcong@gmail.com>, Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:46465 "EHLO
        mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932625AbdJaTQt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 15:16:49 -0400
Received: by mail-io0-f178.google.com with SMTP id 101so1183145ioj.3
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 12:16:48 -0700 (PDT)
In-Reply-To: <1509476381.3828.40.camel@edumazet-glaptop3.roam.corp.google.com>
        (Eric Dumazet's message of "Tue, 31 Oct 2017 11:59:41 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:


[...]

>     CC       iplink_xstats.o
>     CC       ipseg6.o
>     LINK     ip
> xfrm_state.o: In function `xfrm_state_modify.constprop.3':
> xfrm_state.c:(.text+0x2458): undefined reference to `strlcpy'
> ipnetns.o: In function `netns_identify_pid':
> ipnetns.c:(.text+0x12e0): undefined reference to `strlcpy'
> ipxfrm.o: In function `xfrm_state_info_print':
> ipxfrm.c:(.text+0x1c3b): undefined reference to `strlcat'
> ipxfrm.c:(.text+0x1c4d): undefined reference to `strlcat'
> ipxfrm.c:(.text+0x215f): undefined reference to `strlcat'
> ipxfrm.o: In function `xfrm_policy_info_print':
> ipxfrm.c:(.text+0x2299): undefined reference to `strlcat'
> ipxfrm.c:(.text+0x22ab): undefined reference to `strlcat'
> iproute_lwtunnel.o: In function `parse_encap_seg6':
> iproute_lwtunnel.c:(.text+0xa8f): undefined reference to `strlcpy'
> ipvrf.o: In function `vrf_switch':
> ipvrf.c:(.text+0x87d): undefined reference to `strlcpy'
> ipvrf.o: In function `vrf_identify.constprop.2':
> ipvrf.c:(.text+0xe4d): undefined reference to `strlcpy'
> ../lib/libutil.a(bpf.o): In function `bpf_find_mntpt.constprop.10':
> bpf.c:(.text+0x766): undefined reference to `strlcpy'
> ../lib/libutil.a(bpf.o): In function `bpf_get_work_dir':
> bpf.c:(.text+0xb07): undefined reference to `strlcpy'
> ../lib/libutil.a(fs.o):fs.c:(.text+0x44f): more undefined references to
> `strlcpy' follow
> collect2: error: ld returned 1 exit status
> make[1]: *** [ip] Error 1
> make[1]: Leaving directory `/usr/src/iproute2/ip'
> make: *** [all] Error 2

Latest iproute2 has config.mk instead of Config, where a new kludge
-DNEED_STRLCPY has been added.
