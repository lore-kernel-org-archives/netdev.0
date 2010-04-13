From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v2] net: batch skb dequeueing from softnet input_pkt_queue
Date: Wed, 14 Apr 2010 06:43:07 +0800
Message-ID: <y2j412e6f7f1004131543m500ef7f3q2b9210ea58a80755@mail.gmail.com>
References: <1271173102-2980-1-git-send-email-xiaosuo@gmail.com>
	<1271146112.16881.213.camel@edumazet-laptop> <o2v412e6f7f1004130250rdbe17c5dr5c11c3cbbb2f6dbb@mail.gmail.com>
	<20100413155227.GC2538@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:64038 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662Ab0DMWnb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 18:43:31 -0400
Received: by gwaa18 with SMTP id a18so831800gwa.19
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 15:43:30 -0700 (PDT)
In-Reply-To: <20100413155227.GC2538@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 13, 2010 at 11:52 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> On Tue, Apr 13, 2010 at 05:50:29PM +0800, Changli Gao wrote:
>> On Tue, Apr 13, 2010 at 4:08 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0Probably not necessary.
>> >
>> >> + =C2=A0 =C2=A0 volatile bool =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
flush_processing_queue;
>> >
>> > Use of 'volatile' is strongly discouraged, I would say, forbidden.
>>
>> volatile is used to avoid compiler optimization.
>
> Would it be reasonable to use ACCESS_ONCE() where this variable is us=
ed?

Oh, thanks. ACCESS_ONCE() is just what I need.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
