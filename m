From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [Bugme-new] [Bug 7421] New: Oops, EIP is at atalk_sendmsg
Date: Thu, 26 Oct 2006 22:38:41 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0610262233160.31399@bizon.gios.gov.pl>
References: <200610261108.k9QB8a2Q009544@fire-2.osdl.org>
 <20061026094438.48c57c48.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-284524357-1161895121=:31399"
Cc: netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, rose@sj.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:13489 "EHLO
	bizon.gios.gov.pl") by vger.kernel.org with ESMTP id S1423485AbWJZUi4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 16:38:56 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20061026094438.48c57c48.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-284524357-1161895121=:31399
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Thu, 26 Oct 2006, Andrew Morton wrote:

> On Thu, 26 Oct 2006 04:08:36 -0700
> bugme-daemon@bugzilla.kernel.org wrote:
>
>> http://bugzilla.kernel.org/show_bug.cgi?id=3D7421
>>
>>            Summary: Oops, EIP is at atalk_sendmsg
>>     Kernel Version: 2.6.18.1
>>             Status: NEW
>>           Severity: normal
>>              Owner: acme@conectiva.com.br
>>          Submitter: rose@sj.com
>>
>>
>> Distribution: Debian sarge
>> Hardware Environment: i386
>>
>> Problem Description:
>>
>> ct 26 10:01:03 localhost papd[3120]: restart (2.0.3)
>> Oct 26 10:01:07 localhost kernel: BUG: unable to handle kernel NULL poin=
ter \
>>                 dereference at virtual address 00000000
>> Oct 26 10:01:07 localhost kernel:  printing eip:
>> Oct 26 10:01:07 localhost kernel: d0c16a8a
>> Oct 26 10:01:07 localhost kernel: *pde =3D 00000000
>> Oct 26 10:01:07 localhost kernel: Oops: 0000 [#1]
>> Oct 26 10:01:07 localhost kernel: Modules linked in: appletalk psnap llc=
 ipv6 \
>> pcmcia_core af_packet parport_pc parport floppy pcspkr sn d_maestro3
>> snd_ac97_codec \
>> snd_ac97_bus snd_pcm snd_timer snd_page_alloc snd soundcore intel_agp uh=
ci_hcd \
>> usbcore 3c59x mii agpgart mous edev tsdev joydev psmouse ide_cd cdrom rt=
c reiserfs \
>> ext3 jbd ide_disk ide_generic siimage aec62xx trm290 alim15x3 hpt34x hpt=
366
>> cmd64x  \
>> piix rz1000 slc90e66 generic cs5530 cs5520 sc1200 triflex atiixp pdc202x=
x_old \
>> pdc202xx_new opti621 ns87415 cy82c693 amd74xx sis5513 via 82cxxx serverw=
orks
>> ide_core \
>>                 unix
>> Oct 26 10:01:07 localhost kernel: CPU:    0
>> Oct 26 10:01:07 localhost kernel: EIP:    0060:[pg0+277633674/1070257152=
]    Not \
>>                 tainted VLI
>> Oct 26 10:01:07 localhost kernel: EFLAGS: 00010286   (2.6.17.14.2006-10-=
25 #1)
>> Oct 26 10:01:07 localhost kernel: EIP is at atalk_sendmsg+0x15b/0x4e4 [a=
ppletalk]
>> Oct 26 10:01:07 localhost kernel: eax: 00000000   ebx: 0000002f   ecx: 0=
0000000   \
>>                 edx: 00000000
>> Oct 26 10:01:07 localhost kernel: esi: cadcb600   edi: 00000000   ebp: c=
c9d7eec   \
>>                 esp: cc9d7d6c
>> Oct 26 10:01:07 localhost kernel: ds: 007b   es: 007b   ss: 0068
>> Oct 26 10:01:07 localhost kernel: Process afpd (pid: 3118, threadinfo=3D=
cc9d6000 \
>>                 task=3Dcfe205d0)
>> Oct 26 10:01:07 localhost kernel: Stack: 00000000 c02b32c0 00000000 cc9d=
7ee8
>> cffbc500 \
>>                 00000000 d0c16f05 cffbc500
>> Oct 26 10:01:07 localhost kernel:        cffbc500 cc9d7ec8 cadcb600 0000=
0000
>> 00000000 \
>>                 00000400 cc9d7f48 0000001b
>> Oct 26 10:01:07 localhost kernel:        cc9d7ec8 cc9d7e1c cc9d7ee8 c01f=
e97a
>> cc9d7e1c \
>>                 ca252600 cc9d7ec8 0000001b
>> Oct 26 10:01:07 localhost kernel: Call Trace:
>> Oct 26 10:01:07 localhost kernel:  <d0c16f05> atalk_recvmsg+0xf2/0x105
>> [appletalk]  \
>>                 <c01fe97a> sock_sendmsg+0xd0/0xeb
>> Oct 26 10:01:07 localhost kernel:  <c0157bfd> touch_atime+0xb4/0xbb  <c0=
198b22> \
>>                 copy_from_user+0x34/0x5a
>> Oct 26 10:01:07 localhost kernel:  <c012383e> autoremove_wake_function+0=
x0/0x3a  \
>>                 <c0198b22> copy_from_user+0x34/0x5a
>> Oct 26 10:01:07 localhost kernel:  <c01fe490> move_addr_to_kernel+0x24/0=
x39  \
>>                 <c01ffaaa> sys_sendto+0xe9/0x10d
>> Oct 26 10:01:07 localhost kernel:  <c01fe67e> sock_attach_fd+0x72/0xd2  =
<c0143d52> \
>>                 get_empty_filp+0x3b/0xe4
>> Oct 26 10:01:07 localhost kernel:  <c0143d7b> get_empty_filp+0x64/0xe4  =
<c0198ae4> \
>>                 copy_to_user+0x32/0x3c
>> Oct 26 10:01:07 localhost kernel:  <c02001de> sys_socketcall+0xf2/0x180
>> <c0102a03> \
>>                 syscall_call+0x7/0xb
>> Oct 26 10:01:07 localhost kernel: Code: 0c 83 c0 04 eb 15 c6 44 24 1a 00=
 0f b7
>> 86 26 \
>> 01 00 00 66 89 44 24 18 8d 44 24 18 50 e8 e0 eb ff  ff 89 44 24 04 85 f6=
 5d 8b
>> 14 24 \
>>                 <8b> 12 89 54 24 04 74 1b 8b 86 84 00 00 00 f6 c4 04 74 =
10 52 53
>> Oct 26 10:01:07 localhost kernel: EIP: [pg0+277633674/1070257152] \
>>                 atalk_sendmsg+0x15b/0x4e4 [appletalk] SS:ESP 0068:cc9d7d=
6c
>> Oct 26 10:01:21 localhost atalkd[3106]: as_timer gateway 8000.100 down
>>
>>
>>
>> Steps to reproduce:
>> restart the machine, start "papd" after network initializing has finishe=
d
>> a second start of "papd" works fine
>>
>> appletalk is loades as module
>>
>> same behaviour with 2.6.17.14

Something like "me too":

Unable to handle kernel NULL pointer dereference at virtual address 0000000=
0
  printing eip:
c036b1ef
*pde =3D 00000000
Oops: 0000 [#1]
PREEMPT
Modules linked in: bonding
CPU:    0
EIP:    0060:[<c036b1ef>]    Not tainted VLI
EFLAGS: 00010286   (2.6.15.1)
EIP is at atalk_sendmsg+0x158/0x557
eax: d468fee4   ebx: 00000017   ecx: d468fd20   edx: 00000000
esi: 00000000   edi: d7e88200   ebp: bfa7c480   esp: d468fd68
ds: 007b   es: 007b   ss: 0068
Process atalkd (pid: 551, threadinfo=3Dd468e000 task=3Dd6f55090)
Stack: 00000000 d468ff40 00000000 d468fee0 d70d20a0 00000003 c036b6e0 d70d2=
0a0
        d70d20a0 d468fec0 d7e88200 00000000 00000000 00000400 d468ff40 0000=
0003
        d468fec0 d468fe18 bfa7c480 c02e2d5e d468fe18 d7194540 d468fec0 0000=
0003
Call Trace:
  [<c036b6e0>] atalk_recvmsg+0xf2/0x105
  [<c02e2d5e>] sock_sendmsg+0xce/0xe9
  [<c01212c2>] run_timer_softirq+0x185/0x1a0
  [<c012ab68>] autoremove_wake_function+0x0/0x3a
  [<c02e3dba>] sys_sendto+0xcb/0xe9
  [<c013ac70>] free_hot_cold_page+0x78/0xfb
  [<c0161411>] do_select+0x299/0x2ae
  [<c02e4499>] sys_socketcall+0x114/0x1a4
  [<c0102c37>] sysenter_past_esp+0x54/0x75
Code: 0c 83 c0 04 eb 15 c6 44 24 1a 00 0f b7 87 26 01 00 00 66 89 44 24 18 =
8d 44 24 18 50 e8 d8 e9 ff ff 89 44 24 04 58 85 ff 8b 14 24 <8b> 12 89 54 2=
4 04 74 1b 8b 87 80 00 00 00 f6 c4 04 74 10 52 53

Anyway, I have no idea how to reproduce this problem. This server have=20
been up for 49 days so it seems that this is not a very critical problem,=
=20
but still annoying.

Best regards,


 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-284524357-1161895121=:31399--
