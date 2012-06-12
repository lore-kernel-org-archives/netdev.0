From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: Difficulties to get 1Gbps on be2net ethernet card
Date: Tue, 12 Jun 2012 10:24:03 +0200
Message-ID: <CAL8zT=gNtcdyyVcPt5hB6jyF1btzQArEuZgVKWkb0Wd=a4LcVA@mail.gmail.com>
References: <CAL8zT=hHAc5-wGMKgumV=K9jG6tDxzej9Dffe9UYQ24gdWQRtw@mail.gmail.com>
 <CAL8zT=jKhRjVCdYRCerMzimxPAhP5Gi+JBBfuKjG-rfg-LMoVw@mail.gmail.com>
 <1338360536.2760.85.camel@edumazet-glaptop> <CAL8zT=h2hoTWDMpTe8P-xfm-USXD6spx8fFVmm1UXyOfuuqhZw@mail.gmail.com>
 <1338361587.2760.94.camel@edumazet-glaptop> <CAL8zT=jHWhDdv-DyXL8XnL8qRc7o-jZfA7ADU-qt54hB5aLyCw@mail.gmail.com>
 <CAL8zT=gJT1Frn_44SU0CrpZjPxwC_VuHFE4k9jvOGNmFomzhHA@mail.gmail.com>
 <3367B80B08154D42A3B2BC708B5D41F647C678B73F@EXMAIL.ad.emulex.com>
 <CAL8zT=iP+5o11am67ZBVOd=QrOfcjFWDydiuM9RrrAKe_k7LZw@mail.gmail.com>
 <CAL8zT=ggT7Y2on6qmsp3u9CLOCwd6nOr3VjQfEsGZzA+O6us0A@mail.gmail.com>
 <1338980484.2760.4219.camel@edumazet-glaptop> <CAL8zT=hHDPnvRFcQ0w+D=AP+QK6ic4X=tva6Yw_XGwuTbAYjhQ@mail.gmail.com>
 <CAL8zT=jGHo82mo-s8Tfs9LWzfu2GkrS4eZJoeOpHhpXHMr6csg@mail.gmail.com>
 <CAL8zT=jY9YfdkBjk5VhwaSbzghCVUMXZZh+QAgc15LBBztczog@mail.gmail.com>
 <CAL8zT=g67JLZZjLF81+wxe9pmuPZ4EdpY1fHJMQNgcy9R6oBzg@mail.gmail.com>
 <1339072289.3494.3.camel@edumazet-glaptop> <CAL8zT=i2EkZLz3J5ib1tLnOuXt=Buf0sCwr7UbQWRE3B4oB+JQ@mail.gmail.com>
 <1339135709.6001.22.camel@edumazet-glaptop> <CAL8zT=jPUEF62-V_0n9o3=n2Mo6y4M_kGgK+OwdXg0aLDazDgQ@mail.gmail.com>
 <1339143759.6001.53.camel@edumazet-glaptop> <CAL8zT=i6zruaa0-bc-MG4FyhdM8RDtARd2E_o0+G-=p7RsJdGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sathya.Perla@emulex.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:47739 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437Ab2FLIYY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 04:24:24 -0400
Received: by wgbds11 with SMTP id ds11so4130071wgb.1
        for <netdev@vger.kernel.org>; Tue, 12 Jun 2012 01:24:23 -0700 (PDT)
In-Reply-To: <CAL8zT=i6zruaa0-bc-MG4FyhdM8RDtARd2E_o0+G-=p7RsJdGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/6/8 Jean-Michel Hautbois <jhautbois@gmail.com>:
> 2012/6/8 Eric Dumazet <eric.dumazet@gmail.com>:
>> On Fri, 2012-06-08 at 10:14 +0200, Jean-Michel Hautbois wrote:
>>> 2012/6/8 Eric Dumazet <eric.dumazet@gmail.com>:
>>> > On Thu, 2012-06-07 at 14:54 +0200, Jean-Michel Hautbois wrote:
>>> >
>>> >> eth1 =C2=A0 =C2=A0 =C2=A0Link encap:Ethernet =C2=A0HWaddr 68:b5:=
99:b9:8d:d4
>>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 UP BROADCAST RUNNING SLAVE MU=
LTICAST =C2=A0MTU:4096 =C2=A0Metric:1
>>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 RX packets:0 errors:0 dropped=
:0 overruns:0 frame:0
>>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 TX packets:15215387 errors:0 =
dropped:0 overruns:0 carrier:0
>>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 collisions:0 txqueuelen:1000
>>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 RX bytes:0 (0.0 B) =C2=A0TX b=
ytes:61476524359 (57.2 GiB)
>>> >
>>> >> qdisc mq 0: dev eth1 root
>>> >> =C2=A0Sent 61476524359 bytes 15215387 pkt (dropped 45683472, ove=
rlimits 0
>>> >> requeues 17480)
>>> >
>>> > OK, and "tc -s -d cl show dev eth1"
>>> >
>>> > (How many queues are really used)
>>> >
>>> >
>>> >
>>>
>>> tc -s -d cl show dev eth1
>>> class mq :1 root
>>> =C2=A0Sent 9798071746 bytes 2425410 pkt (dropped 3442405, overlimit=
s 0 requeues 2747)
>>> =C2=A0backlog 0b 0p requeues 2747
>>> class mq :2 root
>>> =C2=A0Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>> =C2=A0backlog 0b 0p requeues 0
>>> class mq :3 root
>>> =C2=A0Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>> =C2=A0backlog 0b 0p requeues 0
>>> class mq :4 root
>>> =C2=A0Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>> =C2=A0backlog 0b 0p requeues 0
>>> class mq :5 root
>>> =C2=A0Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>> =C2=A0backlog 0b 0p requeues 0
>>> class mq :6 root
>>> =C2=A0Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>> =C2=A0backlog 0b 0p requeues 0
>>> class mq :7 root
>>> =C2=A0Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>> =C2=A0backlog 0b 0p requeues 0
>>> class mq :8 root
>>> =C2=A0Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>> =C2=A0backlog 0b 0p requeues 0
>>
>>
>> Do you have the same distribution on old kernels as well ?
>> (ie only queue 0 is used)
>>
>>
>>
>
> On the old kernel, there is nothing returned by this command.
>
> JM

I used perf in order to get more information.
Here is the perf record -a sleep 10 result (I took only kernel) :
     6.93%    ModuleTester  [kernel.kallsyms]                 [k]
copy_user_generic_string
     2.99%         swapper  [kernel.kallsyms]                 [k] mwait=
_idle
     2.60%          kipmi0  [ipmi_si]                         [k] port_=
inb
     1.75%         swapper  [kernel.kallsyms]                 [k] rb_pr=
ev
     1.63%    ModuleTester  [kernel.kallsyms]                 [k] _raw_=
spin_lock
     1.43%     NodeManager  [kernel.kallsyms]                 [k] delay=
_tsc
     0.90%    ModuleTester  [kernel.kallsyms]                 [k] clear=
_page_c
     0.88%    ModuleTester  [kernel.kallsyms]                 [k] dev_q=
ueue_xmit
     0.80%              ip  [kernel.kallsyms]                 [k]
snmp_fold_field
     0.73%    ModuleTester  [kernel.kallsyms]                 [k]
clflush_cache_range
     0.69%            grep  [kernel.kallsyms]                 [k] page_=
fault
     0.61%              sh  [kernel.kallsyms]                 [k] page_=
fault
     0.59%    ModuleTester  [kernel.kallsyms]                 [k] udp_s=
endmsg
     0.55%    ModuleTester  [kernel.kallsyms]                 [k] _raw_=
read_lock
     0.53%              sh  [kernel.kallsyms]                 [k] unmap=
_vmas
     0.52%    ModuleTester  [kernel.kallsyms]                 [k] rb_pr=
ev
     0.51%    ModuleTester  [kernel.kallsyms]                 [k]
find_busiest_group
     0.49%    ModuleTester  [kernel.kallsyms]                 [k] __ip_=
make_skb
     0.48%    ModuleTester  [kernel.kallsyms]                 [k]
sock_alloc_send_pskb
     0.48%    ModuleTester  libpthread-2.7.so                 [.]
pthread_mutex_lock
     0.47%    ModuleTester  [kernel.kallsyms]                 [k]
__netif_receive_skb
     0.44%              ip  [kernel.kallsyms]                 [k] find_=
next_bit
     0.43%         swapper  [kernel.kallsyms]                 [k]
clflush_cache_range
     0.41%              ps  [kernel.kallsyms]                 [k] forma=
t_decode
     0.41%    ModuleTester  [bonding]                         [k]
bond_start_xmit
     0.39%    ModuleTester  [be2net]                          [k] be_xm=
it
     0.39%    ModuleTester  [kernel.kallsyms]                 [k]
__ip_append_data
     0.38%    ModuleTester  [kernel.kallsyms]                 [k] netif=
_rx
     0.37%         swapper  [be2net]                          [k] be_po=
ll
     0.37%         swapper  [kernel.kallsyms]                 [k] ktime=
_get
     0.37%              sh  [kernel.kallsyms]                 [k] copy_=
page_c
     0.36%         swapper  [kernel.kallsyms]                 [k]
irq_entries_start
     0.36%    ModuleTester  [kernel.kallsyms]                 [k]
__alloc_pages_nodemask
     0.35%    ModuleTester  [kernel.kallsyms]                 [k] __sla=
b_free
     0.35%    ModuleTester  [kernel.kallsyms]                 [k] ip_mc=
_output
     0.34%    ModuleTester  [kernel.kallsyms]                 [k]
skb_release_data
     0.33%              ip  [kernel.kallsyms]                 [k] page_=
fault
     0.33%    ModuleTester  [kernel.kallsyms]                 [k] udp_s=
end_skb

And here is the perf record -a result without bonding :
     2.49%     ModuleTester  [kernel.kallsyms]               [k]
csum_partial_copy_generic
     1.35%     ModuleTester  [kernel.kallsyms]               [k] _raw_s=
pin_lock
     1.29%     ModuleTester  [kernel.kallsyms]               [k]
clflush_cache_range
     1.16%       jobprocess  [kernel.kallsyms]               [k] rb_pre=
v
     1.01%       jobprocess  [kernel.kallsyms]               [k]
clflush_cache_range
     0.81%     ModuleTester  [be2net]                        [k] be_xmi=
t
     0.78%       jobprocess  [kernel.kallsyms]               [k] __slab=
_free
     0.77%          swapper  [kernel.kallsyms]               [k] mwait_=
idle
     0.72%     ModuleTester  [kernel.kallsyms]               [k]
__domain_mapping
     0.66%       jobprocess  [kernel.kallsyms]               [k] _raw_s=
pin_lock
     0.59%       jobprocess  [kernel.kallsyms]               [k]
_raw_spin_lock_irqsave
     0.56%     ModuleTester  [kernel.kallsyms]               [k] rb_pre=
v
     0.53%          swapper  [kernel.kallsyms]               [k] rb_pre=
v
     0.49%     ModuleTester  [kernel.kallsyms]               [k] sock_w=
malloc
     0.47%       jobprocess  [be2net]                        [k] be_pol=
l
     0.47%     ModuleTester  [kernel.kallsyms]               [k]
kmem_cache_alloc
     0.47%          swapper  [kernel.kallsyms]               [k]
clflush_cache_range
     0.45%           kipmi0  [ipmi_si]                       [k] port_i=
nb
     0.42%          swapper  [kernel.kallsyms]               [k] __slab=
_free
     0.41%       jobprocess  [kernel.kallsyms]               [k] try_to=
_wake_up
     0.40%     ModuleTester  [kernel.kallsyms]               [k]
kmem_cache_alloc_node
     0.40%       jobprocess  [kernel.kallsyms]               [k] tg_loa=
d_down
     0.39%       jobprocess  libodyssey.so.1.8.2             [.]
y8_deblocking_luma_vert_edge_h264_sse2
     0.38%       jobprocess  libodyssey.so.1.8.2             [.]
y8_deblocking_luma_horz_edge_h264_ssse3
     0.38%     ModuleTester  [kernel.kallsyms]               [k] rb_ins=
ert_color
     0.37%       jobprocess  [kernel.kallsyms]               [k] find_i=
ova
     0.37%       jobprocess  [kernel.kallsyms]               [k]
find_busiest_group
     0.36%       jobprocess  libpthread-2.7.so               [.]
pthread_mutex_lock
     0.35%          swapper  [kernel.kallsyms]               [k]
_raw_spin_unlock_irqrestore
     0.34%     ModuleTester  [kernel.kallsyms]               [k]
_raw_spin_lock_irqsave
     0.33%     ModuleTester  [kernel.kallsyms]               [k]
pfifo_fast_dequeue
     0.32%     ModuleTester  [kernel.kallsyms]               [k]
__kmalloc_node_track_caller
     0.32%       jobprocess  [be2net]                        [k]
be_tx_compl_process
     0.31%     ModuleTester  [kernel.kallsyms]               [k] ip_fra=
gment
     0.29%          swapper  [kernel.kallsyms]               [k]
__hrtimer_start_range_ns
     0.29%       jobprocess  [kernel.kallsyms]               [k] __sche=
dule
     0.29%     ModuleTester  [kernel.kallsyms]               [k] dev_qu=
eue_xmit
     0.28%          swapper  [kernel.kallsyms]               [k] __sche=
dule

=46irst thing I notice is the difference in copy_user_generic_string (i=
t
is only 0.11% on the second measure, I didn't reported it here).
I think perf can help in finding the issue I observe with bonding,
maybe do you have  suggestions on the parameters to use ?
=46YI, with bonding, TX goes up to 640Mbps, without bonding, I can send
2.4Gbps without suffering...

JM
