From: Wolfgang Walter <wolfgang.walter@stwm.de>
Subject: Kernel oops with 2.6.26 and ipsec (Was: Re: IPSEC in 2.6.25 causes stalled connections)
Date: Thu, 17 Jul 2008 16:53:59 +0200
Message-ID: <200807171653.59177.wolfgang.walter@stwm.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:58241 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755050AbYGQPzj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 11:55:39 -0400
Received: from mailhub.studentenwerk.mhn.de (mail.studentenwerk.mhn.de [10.148.7.34])
	by email.studentenwerk.mhn.de (Postfix) with ESMTP id A440B58002
	for <netdev@vger.kernel.org>; Thu, 17 Jul 2008 16:53:59 +0200 (CEST)
Received: from mist.as.studentenwerk.mhn.de (mist.as.studentenwerk.mhn.de [10.148.0.198])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mailhub.studentenwerk.mhn.de (Postfix) with ESMTP id A020CDB98E
	for <netdev@vger.kernel.org>; Thu, 17 Jul 2008 16:53:59 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 9. Juli 2008 13:06 schrieben Sie:
> On Wed, Jul 09, 2008 at 12:48:48PM +0200, Wolfgang Walter wrote:
> > If this helps you indeed have a problem with dynamic pmtu.
>
> Do you still see this ICMP problem with the latest 2.6.26 kernel?
> There was a bug fixed in the later 2.6.25 rcs which sounds like
> what you're seeing.

Do you mean the problem with IPSEC and icmp packets generated on the ro=
uter?
Couldn't check yet.

I started testing 2.6.26 but I get a kernel oops, so I switched back to
2.6.25.11. Here is the output of dmesg (no logging was switched on so I=
 don't
have the complete oops). But it happened on several of our routers with=
in one
day:


xe
 [<c01c8c4f>] update+0x0/0x46
 [<c01c8a4d>] final+0x0/0x54
 [<c01c8be4>] digest+0x0/0x6b
 [<c01c8c95>] nosetkey+0x0/0xf
 [<c01c89cc>] init+0x0/0xe
 [<c01c8c4f>] update+0x0/0x46
 [<c01c8a4d>] final+0x0/0x54
 [<c01c8be4>] digest+0x0/0x6b
 [<c01c8c95>] nosetkey+0x0/0xf
 [<c01c89cc>] init+0x0/0xe
 [<c01c8c4f>] update+0x0/0x46
 [<c01c8a4d>] final+0x0/0x54
 [<c01c8be4>] digest+0x0/0x6b
 [<c01c8c95>] nosetkey+0x0/0xf
 [<c01c89cc>] init+0x0/0xe
 [<c01c8c4f>] update+0x0/0x46
 [<c01c8a4d>] final+0x0/0x54
 [<c01c8be4>] digest+0x0/0x6b
 [<c01c8c95>] nosetkey+0x0/0xf
 [<c01c89cc>] init+0x0/0xe
 [<c01c8c4f>] update+0x0/0x46
 [<c01c8a4d>] final+0x0/0x54
 [<c01c8be4>] digest+0x0/0x6b
 [<c01c8c95>] nosetkey+0x0/0xf
 [<c01c89cc>] init+0x0/0xe
 [<c01c8c4f>] update+0x0/0x46
 [<c01c8a4d>] final+0x0/0x54
 [<c01c8be4>] digest+0x0/0x6b
 [<c01c8c95>] nosetkey+0x0/0xf
 [<c01c89cc>] init+0x0/0xe
 [<c01c8c4f>] update+0x0/0x46
 [<c01c8a4d>] final+0x0/0x54
 [<c01c8be4>] digest+0x0/0x6b
 [<c01c8c95>] nosetkey+0x0/0xf
 [<c01c89cc>] init+0x0/0xe
 [<c01c8c4f>] update+0x0/0x46
 [<c01c8a4d>] final+0x0/0x54
 [<c01c8be4>] digest+0x0/0x6b
 [<c01c8c95>] nosetkey+0x0/0xf
 [<c01c89cc>] init+0x0/0xe
 [<c01c8c4f>] update+0x0/0x46
 [<c01c8a4d>] final+0x0/0x54
 [<c01c8be4>] digest+0x0/0x6b
 [<c01c8c95>] nosetkey+0x0/0xf
 [<c01c89cc>] init+0x0/0xe
 [<c01c8c4f>] update+0x0/0x46
 [<c01c8a4d>] final+0x0/0x54
 [<c01c8be4>] digest+0x0/0x6b
 [<c01c8c95>] nosetkey+0x0/0xf
 [<c01c89cc>] init+0x0/0xe
 [<c01c8c4f>] update+0x0/0x46
 [<c01c8a4d>] final+0x0/0x54
 [<c01c8be4>] digest+0x0/0x6b
 [<c01c8c95>] nosetkey+0x0/0xf
 [<c01c89cc>] init+0x0/0xe
 [<c01c8c4f>] update+0x0/0x46
 [<c01c8a4d>] final+0x0/0x54
 [<c01c8be4>] digest+0x0/0x6b
 [<c01c8c95>] nosetkey+0x0/0xf
 [<c01c89cc>] init+0x0/0xe
 [<c01c8c4f>] update+0x0/0x46
 [<c01c8a4d>] final+0x0/0x54
 [<c01c8be4>] digest+0x0/0x6b
 [<c01c8c95>] nosetkey+0x0/0xf
 [<c01c89cc>] init+0x0/0xe
 [<c01c8c4f>] update+0x0/0x46
 [<c01c8a4d>] final+0x0/0x54
 [<c01c8be4>] digest+0x0/0x6b
 [<c01c8c95>] nosetkey+0x0/0xf
 [<c01c89cc>] init+0x0/0xe
 [<c01c8c4f>] update+0x0/0x46
 [<c01c8a4d>] final+0x0/0x54
 [<c01c8be4>] digest+0x0/0x6b
 [<c01c8c95>] nosetkey+0x0/0xf
 [<c0332509>] dst_rcu_free+0x0/0x1c
 [<c0337196>] ip_forward+0x0/0x26e
 [<c0339d4a>] ip_output+0x0/0x90
 [<c0309af5>] dst_discard+0x0/0x8
 [<c0339d4a>] ip_output+0x0/0x90
 [<c0337196>] ip_forward+0x0/0x26e
 [<c0339d4a>] ip_output+0x0/0x90
 [<c0309af5>] dst_discard+0x0/0x8
 [<c0339d4a>] ip_output+0x0/0x90
 [<c0337196>] ip_forward+0x0/0x26e
 [<c0339d4a>] ip_output+0x0/0x90
 [<c01cc47a>] hmac_init+0x0/0x70
 [<c01cc56e>] hmac_update+0x0/0x4e
 [<c01cc4ea>] hmac_final+0x0/0x84
 [<c01cc5bc>] hmac_digest+0x0/0x152
 [<c01cbf2a>] hash_setkey+0x0/0xae
 [<c0337196>] ip_forward+0x0/0x26e
 [<c0339d4a>] ip_output+0x0/0x90
 [<c01cc47a>] hmac_init+0x0/0x70
 [<c01cc56e>] hmac_update+0x0/0x4e
 [<c01cc4ea>] hmac_final+0x0/0x84
 [<c01cc5bc>] hmac_digest+0x0/0x152
 [<c01cbf2a>] hash_setkey+0x0/0xae
 [<c01cc47a>] hmac_init+0x0/0x70
 [<c01cc56e>] hmac_update+0x0/0x4e
 [<c01cc4ea>] hmac_final+0x0/0x84
 [<c01cc5bc>] hmac_digest+0x0/0x152
 [<c01cbf2a>] hash_setkey+0x0/0xae
 [<c01cc47a>] hmac_init+0x0/0x70
 [<c01cc56e>] hmac_update+0x0/0x4e
 [<c01cc4ea>] hmac_final+0x0/0x84
 [<c01cc5bc>] hmac_digest+0x0/0x152
 [<c01cbf2a>] hash_setkey+0x0/0xae
 [<c01cc47a>] hmac_init+0x0/0x70
 [<c01cc56e>] hmac_update+0x0/0x4e
 [<c01cc4ea>] hmac_final+0x0/0x84
 [<c01cc5bc>] hmac_digest+0x0/0x152
 [<c01cbf2a>] hash_setkey+0x0/0xae
 [<c0309af5>] dst_discard+0x0/0x8
 [<c0339d4a>] ip_output+0x0/0x90
 [<c01cc47a>] hmac_init+0x0/0x70
 [<c01cc56e>] hmac_update+0x0/0x4e
 [<c01cc4ea>] hmac_final+0x0/0x84
 [<c01cc5bc>] hmac_digest+0x0/0x152
 [<c01cbf2a>] hash_setkey+0x0/0xae
 [<c01cc47a>] hmac_init+0x0/0x70
 [<c01cc56e>] hmac_update+0x0/0x4e
 [<c01cc4ea>] hmac_final+0x0/0x84
 [<c01cc5bc>] hmac_digest+0x0/0x152
 [<c01cbf2a>] hash_setkey+0x0/0xae
 [<c0332509>] dst_rcu_free+0x0/0x1c
 [<c0337196>] ip_forward+0x0/0x26e
 [<c0339d4a>] ip_output+0x0/0x90
 [<c0337196>] ip_forward+0x0/0x26e
 [<c0339d4a>] ip_output+0x0/0x90
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Code: d2 74 1f 8b 42 50 03 42 4c 39 42 54 73 03 89 42 54 8b 86 cc 00 00=
 00 8b
50 5c 39 50 58 73 03 89 50 58 8b 86 bc 02 00 00 83 c0 04 <ff> 08 0f 94 =
c2 31
c0 84 d2 0f 95 c0 85 c0 89 04 24 74 4f a1 00
EIP: [<c011ea82>] do_exit+0x119/0x54a SS:ESP 0068:d9f4e510
---[ end trace 6ec2fadfd0262e4d ]---
=46ixing recursive fault but reboot is needed!
note: cron[1207] exited with preempt_count 268435459
BUG: unable to handle kernel NULL pointer dereference at 00000004
IP: [<c011ea82>] do_exit+0x119/0x54a
*pde =3D 00000000
Oops: 0002 [#48] PREEMPT
Modules linked in:

Pid: 1207, comm: cron Tainted: G      D W (2.6.26 #1)
EIP: 0060:[<c011ea82>] EFLAGS: 00010202 CPU: 0
EIP is at do_exit+0x119/0x54a
EAX: 00000004 EBX: 10000003 ECX: ffffffff EDX: 00000000
ESI: dc42b130 EDI: 0000000b EBP: c041e382 ESP: d9f4e474
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process cron (pid: 1207, ti=3Dd9f4e000 task=3Ddc42b130 task.ti=3Dd9f4e0=
00)
Stack: 00000002 c041e382 c011cea8 c041ebdc d9f4e494 d9f4e494 d9f4e4d8
 00000206 00000002 c041e382 c010500f 00000000 00000004 dc42b130 0000003=
8
 c01123d8 00000002 d9f4e4d8 00000000 dc42b130 10000003 dc42b130 c0111f5=
0
 c041e382 Call Trace:
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c010513c>] do_invalid_op+0x0/0x6b
 [<c010519e>] do_invalid_op+0x62/0x6b
 [<c011eea4>] do_exit+0x53b/0x54a
 [<c0119b10>] __wake_up_sync+0x26/0x44
 [<c0125731>] do_notify_parent+0x187/0x18e
 [<c012f02f>] getnstimeofday+0x32/0xb2
 [<c012d59f>] ktime_get_ts+0x1d/0x3f
 [<c012d5ce>] ktime_get+0xd/0x21
 [<c01180ff>] hrtick_start_fair+0xc4/0xfd
 [<c039d50a>] error_code+0x6a/0x70
 [<c011eea4>] do_exit+0x53b/0x54a
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c011ea82>] do_exit+0x119/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d50a>] error_code+0x6a/0x70
 [<c010280c>] __switch_to+0x23/0x103
 [<c039bf79>] schedule+0x257/0x2bf
 [<c011a2d5>] check_preempt_wakeup+0x9d/0xbb
 [<c039c053>] preempt_schedule+0x27/0x3c
 [<c011a41f>] wake_up_new_task+0x92/0x96
 [<c011bb52>] do_fork+0x131/0x197
 [<c01020f9>] sys_clone+0x28/0x2d
 [<c01037a2>] syscall_call+0x7/0xb
 [<c0320794>] sfq_drop+0x100/0x215
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Code: d2 74 1f 8b 42 50 03 42 4c 39 42 54 73 03 89 42 54 8b 86 cc 00 00=
 00 8b
50 5c 39 50 58 73 03 89 50 58 8b 86 bc 02 00 00 83 c0 04 <ff> 08 0f 94 =
c2 31
c0 84 d2 0f 95 c0 85 c0 89 04 24 74 4f a1 00
EIP: [<c011ea82>] do_exit+0x119/0x54a SS:ESP 0068:d9f4e474
------------[ cut here ]------------
WARNING: at crypto/blkcipher.c:327 blkcipher_walk_first+0x46/0x15d()



--
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
