From: Sunny <sunyucong@gmail.com>
Subject: Re: tcp_fastretrans_alert since 2.6.32 ?
Date: Fri, 24 Sep 2010 19:34:47 -0700
Message-ID: <AANLkTik1bgLv9+rmx_swJuZ70dscjh=AmafWn3uu8FY5@mail.gmail.com>
References: <AANLkTinnaA3Qgny45BRyW3i5u+nXn1XgWwkxA_QbN8xN@mail.gmail.com>
	<1285138126.6378.174.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1285138126.6378.174.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ping, anyone?

On Tue, Sep 21, 2010 at 11:48 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> CC netdev and Ilpo
>
> Le mardi 21 septembre 2010 =E0 23:37 -0700, Sunny a =E9crit :
>> Hi,
>>
>> After upgrading to the latest ubuntu kernel, I started to have this
>> alert showing up, this is a vm running on ESXi host with vmxnet3
>> adapter, mainly serving large traffic ~70Mbps towards overboard
>> customers, so I expect packet loss and retrans is pretty high. So I'=
m
>> posting to ask whether others been seeing the same issue? When this
>> happens, machine freeze several seconds for about three times in a r=
ow
>> then seems to start working again.
>>
>> Please cc me on the thread, thanks in advance.
>>
>>
>> [212670.327617] ------------[ cut here ]------------
>> [212670.327689] WARNING: at
>> /build/buildd/linux-2.6.32/net/ipv4/tcp_input.c:2919 tcp_fastret
>> rans_alert+0x3f9/0xd90()
>> [212670.327692] Hardware name: VMware Virtual Platform
>> [212670.327693] Modules linked in: btrfs zlib_deflate crc32c libcrc3=
2c
>> ufs qnx4 hfsplus hfs =A0minix ntfs vfat msdos fat jfs xfs exportfs
>> reiserfs sch_sfq cls_u32 sch_htb nf_conntrack_ipv 6 ip6table_filter
>> ip6_tables xt_tcpudp xt_state xt_multiport iptable_filter iptable_na=
t
>> nf_n at nf_conntrack_ipv4 sit nf_conntrack nf_defrag_ipv4 tunnel4
>> ip_tables x_tables acpiphp ppde v psmouse parport_pc serio_raw fbcon
>> tileblit font bitblit softcursor vmxnet3 vga16fb vgasta te lp parpor=
t
>> floppy vmw_pvscsi
>> [212670.327741] Pid: 0, comm: swapper Not tainted 2.6.32-24-server #=
42-Ubuntu
>> [212670.327742] Call Trace:
>> [212670.327744] =A0<IRQ> =A0[<ffffffff81066dab>] warn_slowpath_commo=
n+0x7b/0xc0
>> [212670.327754] =A0[<ffffffff81066e04>] warn_slowpath_null+0x14/0x20
>> [212670.327757] =A0[<ffffffff814b98f9>] tcp_fastretrans_alert+0x3f9/=
0xd90
>> [212670.327759] =A0[<ffffffff814bad24>] tcp_ack+0x284/0x6b0
>> [212670.327762] =A0[<ffffffff814bbab0>] tcp_rcv_established+0x400/0x=
730
>> [212670.327766] =A0[<ffffffff814c3553>] tcp_v4_do_rcv+0xf3/0x160
>> [212670.327769] =A0[<ffffffff814c4ca5>] tcp_v4_rcv+0x5b5/0x7e0
>> [212670.327772] =A0[<ffffffff814a2c00>] ? ip_local_deliver_finish+0x=
0/0x2d0
>> [212670.327776] =A0[<ffffffff8149a6b4>] ? nf_hook_slow+0x74/0x100
>> [212670.327779] =A0[<ffffffff814a2c00>] ? ip_local_deliver_finish+0x=
0/0x2d0
>> [212670.327781] =A0[<ffffffff814a2cdd>] ip_local_deliver_finish+0xdd=
/0x2d0
>> [212670.327783] =A0[<ffffffff814a2f60>] ip_local_deliver+0x90/0xa0
>> [212670.327785] =A0[<ffffffff814a241d>] ip_rcv_finish+0x12d/0x440
>> [212670.327787] =A0[<ffffffff814a29a5>] ip_rcv+0x275/0x360
>> [212670.327794] =A0[<ffffffff8147319a>] netif_receive_skb+0x38a/0x5d=
0
>> [212670.327801] =A0[<ffffffffa005203c>]
>> vmxnet3_rq_rx_complete+0x23c/0x610 [vmxnet3]
>> [212670.327806] =A0[<ffffffffa005245f>] vmxnet3_do_poll+0x4f/0xf0 [v=
mxnet3]
>> [212670.327809] =A0[<ffffffffa005252d>] vmxnet3_poll+0x2d/0x60 [vmxn=
et3]
>> [212670.327816] =A0[<ffffffff810397a9>] ? default_spin_lock_flags+0x=
9/0x10
>> [212670.327820] =A0[<ffffffff81473c8f>] net_rx_action+0x10f/0x250
>> [212670.327824] =A0[<ffffffff8106e2f7>] __do_softirq+0xb7/0x1e0
>> [212670.327828] =A0[<ffffffff810c4d40>] ? handle_IRQ_event+0x60/0x17=
0
>> [212670.327833] =A0[<ffffffff810142ec>] call_softirq+0x1c/0x30
>> [212670.327836] =A0[<ffffffff81015cb5>] do_softirq+0x65/0xa0
>> [212670.327837] =A0[<ffffffff8106e195>] irq_exit+0x85/0x90
>> [212670.327845] =A0[<ffffffff8155fd45>] do_IRQ+0x75/0xf0
>> [212670.327848] =A0[<ffffffff81013b13>] ret_from_intr+0x0/0x11
>> [212670.327849] =A0<EOI> =A0[<ffffffff81038acb>] ? native_safe_halt+=
0xb/0x10
>> [212670.327855] =A0[<ffffffff8101b69d>] ? default_idle+0x3d/0x90
>> [212670.327860] =A0[<ffffffff81011e63>] ? cpu_idle+0xb3/0x110
>> [212670.327867] =A0[<ffffffff81552b53>] ? start_secondary+0xa8/0xaa
>> [212670.327869] ---[ end trace e26694ca94def524 ]---
>>
>>
>> Here's netstat -s output
>>
>> Ip:
>> =A0 =A0 362267935 total packets received
>> =A0 =A0 0 forwarded
>> =A0 =A0 0 incoming packets discarded
>> =A0 =A0 362257901 incoming packets delivered
>> =A0 =A0 326868094 requests sent out
>> =A0 =A0 9 fragments dropped after timeout
>> =A0 =A0 2777 reassemblies required
>> =A0 =A0 1357 packets reassembled ok
>> =A0 =A0 9 packet reassembles failed
>> =A0 =A0 490 fragments received ok
>> =A0 =A0 1034 fragments created
>> Icmp:
>> =A0 =A0 22430 ICMP messages received
>> =A0 =A0 283 input ICMP message failed.
>> =A0 =A0 ICMP input histogram:
>> =A0 =A0 =A0 =A0 destination unreachable: 17113
>> =A0 =A0 =A0 =A0 timeout in transit: 613
>> =A0 =A0 =A0 =A0 redirects: 9
>> =A0 =A0 =A0 =A0 echo requests: 4685
>> =A0 =A0 =A0 =A0 echo replies: 10
>> =A0 =A0 7383 ICMP messages sent
>> =A0 =A0 0 ICMP messages failed
>> =A0 =A0 ICMP output histogram:
>> =A0 =A0 =A0 =A0 destination unreachable: 2695
>> =A0 =A0 =A0 =A0 echo request: 11
>> =A0 =A0 =A0 =A0 echo replies: 4677
>> IcmpMsg:
>> =A0 =A0 =A0 =A0 InType0: 10
>> =A0 =A0 =A0 =A0 InType3: 17113
>> =A0 =A0 =A0 =A0 InType5: 9
>> =A0 =A0 =A0 =A0 InType8: 4685
>> =A0 =A0 =A0 =A0 InType11: 613
>> =A0 =A0 =A0 =A0 OutType0: 4677
>> =A0 =A0 =A0 =A0 OutType3: 2695
>> =A0 =A0 =A0 =A0 OutType8: 11
>> Tcp:
>> =A0 =A0 6563076 active connections openings
>> =A0 =A0 1610183 passive connection openings
>> =A0 =A0 1646225 failed connection attempts
>> =A0 =A0 75246 connection resets received
>> =A0 =A0 1141 connections established
>> =A0 =A0 361192315 segments received
>> =A0 =A0 323797760 segments send out
>> =A0 =A0 1997456 segments retransmited
>> =A0 =A0 12990 bad segments received.
>> =A0 =A0 1851272 resets sent
>> Udp:
>> =A0 =A0 4138313 packets received
>> =A0 =A0 186 packets to unknown port received.
>> =A0 =A0 0 packet receive errors
>> =A0 =A0 4161268 packets sent
>> UdpLite:
>> TcpExt:
>> =A0 =A0 5096 invalid SYN cookies received
>> =A0 =A0 167 resets received for embryonic SYN_RECV sockets
>> =A0 =A0 58826 packets pruned from receive queue because of socket bu=
ffer overrun
>> =A0 =A0 312 packets pruned from receive queue
>> =A0 =A0 19 packets dropped from out-of-order queue because of socket=
 buffer overrun
>> =A0 =A0 365 ICMP packets dropped because they were out-of-window
>> =A0 =A0 2712111 TCP sockets finished time wait in fast timer
>> =A0 =A0 82068 time wait sockets recycled by time stamp
>> =A0 =A0 311 packets rejects in established connections because of ti=
mestamp
>> =A0 =A0 11516250 delayed acks sent
>> =A0 =A0 6415 delayed acks further delayed because of locked socket
>> =A0 =A0 Quick ack mode was activated 208750 times
>> =A0 =A0 41789 packets directly queued to recvmsg prequeue.
>> =A0 =A0 1 bytes directly in process context from backlog
>> =A0 =A0 2969 bytes directly received in process context from prequeu=
e
>> =A0 =A0 155660989 packet headers predicted
>> =A0 =A0 55448128 acknowledgments not containing data payload receive=
d
>> =A0 =A0 89389461 predicted acknowledgments
>> =A0 =A0 9544 times recovered from packet loss due to fast retransmit
>> =A0 =A0 585991 times recovered from packet loss by selective acknowl=
edgements
>> =A0 =A0 710 bad SACK blocks received
>> =A0 =A0 Detected reordering 1944 times using FACK
>> =A0 =A0 Detected reordering 26599 times using SACK
>> =A0 =A0 Detected reordering 267 times using reno fast retransmit
>> =A0 =A0 Detected reordering 1819 times using time stamp
>> =A0 =A0 3169 congestion windows fully recovered without slow start
>> =A0 =A0 26810 congestion windows partially recovered using Hoe heuri=
stic
>> =A0 =A0 14402 congestion windows recovered without slow start by DSA=
CK
>> =A0 =A0 40392 congestion windows recovered without slow start after =
partial ack
>> =A0 =A0 115772 TCP data loss events
>> =A0 =A0 TCPLostRetransmit: 5320
>> =A0 =A0 1922 timeouts after reno fast retransmit
>> =A0 =A0 69095 timeouts after SACK recovery
>> =A0 =A0 11101 timeouts in loss state
>> =A0 =A0 1151834 fast retransmits
>> =A0 =A0 74479 forward retransmits
>> =A0 =A0 225380 retransmits in slow start
>> =A0 =A0 275631 other TCP timeouts
>> =A0 =A0 2606 classic Reno fast retransmits failed
>> =A0 =A0 30507 SACK retransmits failed
>> =A0 =A0 4862645 packets collapsed in receive queue due to low socket=
 buffer
>> =A0 =A0 260934 DSACKs sent for old packets
>> =A0 =A0 5109 DSACKs sent for out of order packets
>> =A0 =A0 95650 DSACKs received
>> =A0 =A0 819 DSACKs for out of order packets received
>> =A0 =A0 28142 connections reset due to unexpected data
>> =A0 =A0 22325 connections reset due to early user close
>> =A0 =A0 85423 connections aborted due to timeout
>> =A0 =A0 TCPSACKDiscard: 2319
>> =A0 =A0 TCPDSACKIgnoredOld: 52587
>> =A0 =A0 TCPDSACKIgnoredNoUndo: 29859
>> =A0 =A0 TCPSpuriousRTOs: 2605
>> =A0 =A0 TCPSackShifted: 3539688
>> =A0 =A0 TCPSackMerged: 3241543
>> =A0 =A0 TCPSackShiftFallback: 8938458
>> IpExt:
>> =A0 =A0 InMcastPkts: 2105
>> =A0 =A0 InBcastPkts: 12
>> =A0 =A0 InOctets: 1670966745
>> =A0 =A0 OutOctets: -417434189
>> =A0 =A0 InMcastOctets: 58940
>> =A0 =A0 InBcastOctets: 1792
>
>
>
