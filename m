From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: 2.6.17-mm3
Date: Sat, 08 Jul 2006 12:51:28 +0200
Message-ID: <44AF8E30.2000603@gmail.com>
References: <20060627015211.ce480da6.akpm@osdl.org>	<6bffcb0e0606270712w166f04a6u237d695e2bfa1913@mail.gmail.com> <20060707192227.1d95ca0e@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>,
	Arjan van de Ven <arjan@linux.intel.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:10454 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751298AbWGHKv0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jul 2006 06:51:26 -0400
Received: by nf-out-0910.google.com with SMTP id o60so80011nfa
        for <netdev@vger.kernel.org>; Sat, 08 Jul 2006 03:51:24 -0700 (PDT)
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060707192227.1d95ca0e@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger napisa=C5=82(a):
> On Tue, 27 Jun 2006 16:12:42 +0200
> "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com> wrote:
>=20
>> Hi,
>>
>> On 27/06/06, Andrew Morton <akpm@osdl.org> wrote:
>>> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.1=
7/2.6.17-mm3/
>>>
>>>
>> It looks like a skge bug
>>
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> [ INFO: possible irq lock inversion dependency detected ]
>> ---------------------------------------------------------
>> swapper/0 just changed the state of lock:
>>  (tasklist_lock){..-?}, at: [<c0128092>] send_group_sig_info+0x16/0x=
34
>> but this lock took another, soft-irq-unsafe lock in the past:
>>   (&sig->stats_lock){--..}
>>
>> and interrupts could create inverse lock ordering between them.
>>
>>
>> other info that might help us debug this:
>> no locks held by swapper/0.
>>
>> the first lock's dependencies:
>> -> (tasklist_lock){..-?} ops: 13763 {
>>    initial-use  at:
>>                         [<c01353ab>] lock_acquire+0x60/0x80
>>                         [<c02d0ce2>] _write_lock_irq+0x29/0x38
>>                         [<c011c4e3>] copy_process+0xea7/0x13c0
>>                         [<c011cc6a>] do_fork+0x8d/0x18f
>>                         [<c010136c>] kernel_thread+0x6c/0x74
>>                         [<c0100518>] rest_init+0x14/0x3c
>>                         [<c03b6769>] start_kernel+0x388/0x390
>>                         [<c0100210>] 0xc0100210
>>    in-softirq-R at:
>> [..]
>>
>> Here is a dmesg log http://www.stardust.webpages.pl/files/mm/2.6.17-=
mm3/mm-dmesg
>=20
>=20
> That file no longer exists...

It was moved, sorry.

Regards,
Michal

--=20
Michal K. K. Piotrowski
LTG - Linux Testers Group
(http://www.stardust.webpages.pl/ltg/wiki/)
