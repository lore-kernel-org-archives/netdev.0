From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: kenel level packet capturing
Date: Wed, 14 Dec 2011 14:31:25 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1112141426450.16886@frira.zrqbmnf.qr>
References: <CAKj1SsOnYsOXjRBKm+=hTnEiesXrC3h0Q-KN2b61nPSQud9wMA@mail.gmail.com> <20111019123733.GA21324@synalogic.ca> <CAKj1SsOra7u21u8Zq9rDLzv_Bhx8sPsah+SHByMYQbVc_j6LQA@mail.gmail.com> <20111213.133629.1213042365300662857.davem@davemloft.net>
 <CAKj1SsNO_uJuVtKs_-tygcd=QDesKkYa=9DVeajhK73LFV-opA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
To: raviraj joshi <raviraj.j1991@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAKj1SsNO_uJuVtKs_-tygcd=QDesKkYa=9DVeajhK73LFV-opA@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2011-12-14 11:46, raviraj joshi wrote:
>On Wed, Dec 14, 2011 at 12:06 AM, David Miller wrote:
>>
>>>We have decided to use PF_RING(a kernel module to capture packets)
>>>for the same due to the number of advantages.
>>
>>What "advantages"? =C2=A0The AF_PACKET socket layer already upstream =
in
>>the kernel supports every relevant performance feature PF_RING
>>does, and then some.
>
>I refered to the document on "A Measurement Study of Packet
>Reception using Linux"[1] which said pf_ring maintains a ring
>buffer, so we dont have to issue a receive system call for each
>packet in contrast to AF_PACKET which issues a system call for each
>packet(pls correct me if i am wrong).

AF_PACKET has had mmap support for a loooong time. The initial code
traces back to 2.3.15pre3 (1999-Aug-23).
So much for $academia.

>[1]
>http://www.cs.wustl.edu/~jain/cse567-11/ftp/pkt_recp/index.html
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
