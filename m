From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 3318] New: TC crashes my Kernel 2.6.8.1, but
 do not crash my kernel 2.6.7!!!
Date: Tue, 31 Aug 2004 08:19:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040831081930.3d9edc17.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Tue, 31 Aug 2004 06:41:48 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 3318] New: TC crashes my Kernel 2.6.8.1, but do not crash my kernel 2.6.7!!!


http://bugme.osdl.org/show_bug.cgi?id=3318

           Summary: TC crashes my Kernel 2.6.8.1, but do not crash my kernel
                    2.6.7!!!
    Kernel Version: 2.6.8.1
            Status: NEW
          Severity: blocking
             Owner: acme@conectiva.com.br
         Submitter: bluelightning.other.stuff@mantech.ro


Distribution: Mandrake 10 & Debian 3 r2
Hardware Environment: AMD K7 Duron 900Mhz or AMD K7 XP 1500+
Software Environment: iproute2-2.4.7-now-ss020116-try.tar.bz2
                      iproute2-2.6.8-040823.tar.gz
                      iproute2-2.6.9-jamal.tgz

Problem Description: when i try to asign classes and u32 filter with htb with
tc, my kernel crashes. It gives my this messege:

Aug 31 11:43:45 localhost kernel: c0260150
Aug 31 11:43:45 localhost kernel: PREEMPT
Aug 31 11:43:45 localhost kernel: Modules linked in: sch_htb nfsd exportfs lockd
 sunrpc md5 ipv6 snd_via82xx snd_ac97_codec snd_pcm snd_timer snd_page_alloc snd
_mpu401_uart snd_rawmidi snd soundcore ip_gre ide_cd cdrom 8139too ne2k_pci 8390
 crc32 nls_iso8859_1 nls_cp850 vfat fat supermount md via_agp uhci_hcd usbcore r
eiserfs
Aug 31 11:43:45 localhost kernel: CPU:    0
Aug 31 11:43:45 localhost kernel: EIP:    0060:[gen_new_kid+32/80]    Not tainte
d
Aug 31 11:43:45 localhost kernel: EIP:    0060:[<c0260150>]    Not tainted
Aug 31 11:43:45 localhost kernel: EFLAGS: 00010206   (2.6.8.1)
Aug 31 11:43:45 localhost kernel: eax: 00000803   ebx: 80000000   ecx: 00000803
  edx: 000003e8
Aug 31 11:43:45 localhost kernel: esi: c6769e60   edi: 00000000   ebp: c6769c40
  esp: c586dbb4
Aug 31 11:43:45 localhost kernel: ds: 007b   es: 007b   ss: 0068
Aug 31 11:43:45 localhost kernel: Process tc (pid: 7034, threadinfo=c586c000 tas
k=c847ec90)
Aug 31 11:43:45 localhost kernel: Stack: c65f9520 c02606b6 c6769c40 80000000 c9c
1b830 0000003c 00000001 00000001
Aug 31 11:43:45 localhost kernel:        00000013 00000013 00000013 c9c1b830 000
00000 00000000 00000000 c9c1b838
Aug 31 11:43:45 localhost kernel:        00000000 00000000 00000000 00000000 000
01000 c98e4aa4 00000000 c65f9520
Aug 31 11:43:45 localhost kernel: Call Trace:
Aug 31 11:43:45 localhost kernel:  [u32_change+598/1104]
Aug 31 11:43:45 localhost kernel:  [<c02606b6>]
Aug 31 11:43:45 localhost kernel:  [tc_ctl_tfilter+957/1552]
Aug 31 11:43:45 localhost kernel:  [<c025c0bd>]
Aug 31 11:43:45 localhost kernel:  [rtnetlink_rcv+808/912]
Aug 31 11:43:45 localhost kernel:  [<c0254f18>]
Aug 31 11:43:45 localhost kernel:  [netlink_dump+177/560]
Aug 31 11:43:45 localhost kernel:  [<c0266cc1>]
Aug 31 11:43:45 localhost kernel:  [netlink_data_ready+90/112]
Aug 31 11:43:45 localhost kernel:  [<c0266afa>]
Aug 31 11:43:45 localhost kernel:  [netlink_sendskb+140/192]
Aug 31 11:43:45 localhost kernel:  [<c026610c>]
Aug 31 11:43:45 localhost kernel:  [netlink_sendmsg+534/768]
Aug 31 11:43:45 localhost kernel:  [<c0266786>]
Aug 31 11:43:45 localhost kernel:  [sock_sendmsg+183/272]
Aug 31 11:43:45 localhost kernel:  [<c0243277>]
Aug 31 11:43:45 localhost kernel:  [sock_sendmsg+183/272]
Aug 31 11:43:45 localhost kernel:  [<c0243277>]
Aug 31 11:43:45 localhost kernel:  [verify_iovec+60/160]
Aug 31 11:43:45 localhost kernel:  [<c024945c>]
Aug 31 11:43:45 localhost kernel:  [sys_sendmsg+415/576]
Aug 31 11:43:45 localhost kernel:  [<c0244f5f>]
Aug 31 11:43:45 localhost kernel:  [do_no_page+111/880]
Aug 31 11:43:45 localhost kernel:  [<c0145dcf>]
Aug 31 11:43:45 localhost kernel:  [handle_mm_fault+360/512]
Aug 31 11:43:45 localhost kernel:  [<c0146368>]
Aug 31 11:43:45 localhost kernel:  [do_page_fault+425/1471]
Aug 31 11:43:45 localhost kernel:  [<c0116e39>]
Aug 31 11:43:45 localhost kernel:  [update_process_times+70/96]
Aug 31 11:43:45 localhost kernel:  [<c0123f76>]
Aug 31 11:43:45 localhost kernel:  [update_wall_time+11/64]
Aug 31 11:43:45 localhost kernel:  [<c0123ddb>]
Aug 31 11:43:45 localhost kernel:  [rcu_check_quiescent_state+117/144]
Aug 31 11:43:45 localhost kernel:  [<c012bc65>]
Aug 31 11:43:45 localhost kernel:  [copy_from_user+66/112]
Aug 31 11:43:45 localhost kernel:  [<c01aec32>]
Aug 31 11:43:45 localhost kernel:  [sys_socketcall+137/608]
Aug 31 11:43:45 localhost kernel:  [<c02452b9>]
Aug 31 11:43:45 localhost kernel:  [sysenter_past_esp+82/113]
Aug 31 11:43:45 localhost kernel:  [<c0106159>]
Aug 31 11:43:45 localhost kernel: Code: 8b 42 04 8b 12 25 ff 0f 00 00 39 c1 0f 4
                2 c8 85 d2 75 ed 41


Steps to reproduce:
This is a part of my script that i use to create the traffic shapping:

#!/bin/sh
echo -en "\033[1;39m"
DEV=eth2
TC="/usr/sbin/tc"
#TC="/home/Kitts/iproute2/iproute2/tc/tc"
U32="$TC filter add dev $DEV protocol ip parent 1:0 prio 1 u32"
echo
echo -e "HTB Script-create \033[1;35mV3.0\033[1;39m for\033[1;32m
outgoing\033[1;39m trafic on device\033[1;34m $DEV\033[1;39m"
echo "Del prev root"
$TC qdisc del dev $DEV root
echo "Add new root class - handle 1:"
$TC qdisc add dev $DEV root handle 1: htb default 15
echo "|-Add LAN band (this is o root class!) - classid 1:1, parent 1:"
$TC class add dev $DEV parent 1: classid 1:1 htb rate 100Mbit ceil 100Mbit burst
32k quantum 1536
    $TC class add dev $DEV parent 1:1 classid 1:0x20 htb rate 24Mbit ceil
100Mbit burst 32k quantum 1536
    echo -e "| |-Add FROM\033[1;32m LAN 80.97.163.0/28\033[1;39m TO\033[1;32m
other LANs\033[1;39m class band - classid 1:0x20, parent 1:1"
      $U32 match ip src 80.97.163.0/28 match ip dst 80.97.163.0/28 flowid 1:0x20
      $U32 match ip src 80.97.163.0/28 match ip dst 192.168.0.0/24 flowid 1:0x20
      $U32 match ip src 80.97.163.0/28 match ip dst 172.16.0.0/28 flowid 1:0x20
      $U32 match ip src 80.97.163.0/28 match ip dst 172.16.1.0/24 flowid 1:0x20
      $U32 match ip src 80.97.163.0/28 match ip dst 192.168.1.0/24 flowid 1:0x20
      $U32 match ip src 80.97.163.0/28 match ip dst 255.255.255.255/32 flowid 1:0x20
      $TC qdisc add dev $DEV parent 1:0x20 handle 0x20: pfifo
    $TC class add dev $DEV parent 1:1 classid 1:0x21 htb rate 24Mbit ceil
100Mbit burst 32k quantum 1536
    echo -e "| |-Add FROM\033[1;32m LAN 192.168.0.0/24\033[1;39m TO\033[1;32m
other LANs\033[1;39m class band - classid 1:0x21, parent 1:1"
      $U32 match ip src 192.168.0.0/24 match ip dst 192.168.0.0/24 flowid 1:0x21
      $U32 match ip src 192.168.0.0/24 match ip dst 192.168.1.0/24 flowid 1:0x21
      $U32 match ip src 192.168.0.0/24 match ip dst 80.97.163.0/28 flowid 1:0x21
      $U32 match ip src 192.168.0.0/24 match ip dst 172.16.0.0/28 flowid 1:0x21
      $U32 match ip src 192.168.0.0/24 match ip dst 172.16.1.0/24 flowid 1:0x21
      $U32 match ip src 192.168.0.0/24 match ip dst 255.255.255.255/32 flowid 1:0x21
      $TC qdisc add dev $DEV parent 1:0x21 handle 0x21: pfifo
    $TC class add dev $DEV parent 1:1 classid 1:0x22 htb rate 24Mbit ceil
100Mbit burst 32k quantum 1536
    echo -e "| |-Add FROM\033[1;32m LAN 172.16.0.0/28\033[1;39m TO\033[1;32m
other LANs\033[1;39m class band - classid 1:0x22, parent 1:1"
      $U32 match ip src 172.16.0.0/28 match ip dst 172.16.0.0/28 flowid 1:0x22
      $U32 match ip src 172.16.0.0/28 match ip dst 172.16.1.0/24 flowid 1:0x22
      $U32 match ip src 172.16.0.0/28 match ip dst 80.97.163.0/28 flowid 1:0x22
      $U32 match ip src 172.16.0.0/28 match ip dst 192.168.0.0/24 flowid 1:0x22
      $U32 match ip src 172.16.0.0/28 match ip dst 192.168.1.0/24 flowid 1:0x22
      $U32 match ip src 172.16.0.0/28 match ip dst 255.255.255.255/32 flowid 1:0x22
      $TC qdisc add dev $DEV parent 1:0x22 handle 0x22: pfifo
    $TC class add dev $DEV parent 1:1 classid 1:0x23 htb rate 24Mbit ceil
100Mbit burst 32k quantum 1536
    echo -e "| |-Add FROM\033[1;32m LAN 172.16.100.0/30\033[1;39m TO\033[1;32m
other LANs\033[1;39m class band - classid 1:0x23, parent 1:1"
      $U32 match ip src 172.16.100.0/30 match ip dst 172.16.100.0/30 flowid 1:0x23
      $U32 match ip src 172.16.100.0/30 match ip dst 255.255.255.255/32 flowid
1:0x23
      $TC qdisc add dev $DEV parent 1:0x23 handle 0x23: pfifo

I've tried on 2 sistems and 2 OS-es. The tc works very fine on kernel 2.6.7!!!
Same script, same tc!!!

TC="/home/Kitts/iproute2/iproute2/tc/tc" -> is the tc version ss020116, i use
this path because i do not want to install over my current iproute2 version ss040823

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
