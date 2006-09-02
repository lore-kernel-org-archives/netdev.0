From: "Franco" <franco.daje@virgilio.it>
Subject: Re: i not find in the kernel code the code of this command
Date: Sat, 2 Sep 2006 03:22:17 +0200
Message-ID: <000401c6ce2e$3b7998c0$0201a8c0@PCFranco>
References: <003a01c6cdd1$7151c100$0201a8c0@PCFranco> <5640c7e00609011704v2a1e7c38x1ede5f7b3dc4539f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1;
	format=flowed	reply-type=response
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vsmtp2.tin.it ([212.216.176.222]:34497 "EHLO vsmtp2.tin.it")
	by vger.kernel.org with ESMTP id S1750718AbWIBBWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 21:22:21 -0400
To: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

thanks for your response!
Yes, The code is under net/sched in the source tree.
The file act_police.c in the directoy net/sched don't exist. there is=20
police.c that have a very similar code act_police.c (that i have found =
on=20
internet)

however i have doon 'make menuconfig', i have gone to traffic policing =
and=20
it is selectionated but there is only the "*". there isn't "M" that mea=
ns=20
"modularized featured" and i can't insert M in traffic policing
you have help me very much with this last information. But, at this poi=
nt,=20
if i want create a proc file in police.c, therefore modificate the kern=
el, i=20
must install on my pc another version on linux. It is exact?
Thanks
bye

=46ranco

----- Original Message -----=20
=46rom: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
To: "Franco" <franco.daje@virgilio.it>
Cc: <netdev@vger.kernel.org>
Sent: Saturday, September 02, 2006 2:04 AM
Subject: Re: i not find in the kernel code the code of this command


> On 9/2/06, Franco <franco.daje@virgilio.it> wrote:
>> I thought that this code was police.c but seem that it isn't
>> i must implement a proc file in the code and recompiling the kernel.
>>
> I'm not sure I understand your question. Please tell me if I answer w=
rong!
>
> The code is under net/sched in the source tree. The main file is
> act_police.c but it is in use elsewhere as well. grep for POLICE.
>
> To build the code you need to alter your kernel options under 'make
> menuconfig' Networking, Networking Options, Qos and/or fair queueing,
> Actions must be selected and then Traffic Police.
>
> I hope this helps.
>
> Ian
> --=20
> Ian McDonald
> Web: http://wand.net.nz/~iam4
> Blog: http://imcdnzl.blogspot.com
> WAND Network Research Group
> Department of Computer Science
> University of Waikato
> New Zealand
>
> __________ Informazione NOD32 1.1607 (20060619) __________
>
> Questo messaggio  =E8 stato controllato dal Sistema Antivirus NOD32
> http://www.nod32.it
>
>=20


--=20
VGER BF report: U 0.502266
