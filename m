From: raj ravi <mekaviraj@gmail.com>
Subject: Re: tcp_reordering as 0 possible?
Date: Wed, 17 Mar 2010 17:53:43 +0530
Message-ID: <de0a9dcb1003170523v104ec57bs6ab31161c75131f1@mail.gmail.com>
References: <de0a9dcb1003150725h367d0548j35037441fdb2f5df@mail.gmail.com>
	 <alpine.DEB.2.00.1003171333250.19416@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f198.google.com ([209.85.216.198]:39668 "EHLO
	mail-px0-f198.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754720Ab0CQMXn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 08:23:43 -0400
Received: by pxi36 with SMTP id 36so454884pxi.21
        for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 05:23:43 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1003171333250.19416@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 17, 2010 at 5:08 PM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:
> On Mon, 15 Mar 2010, raj ravi wrote:
>
>> what is the behaviour in TCP stack if I set tcp_reordering as 0.
>> So , sender will =A0start retransmission without waiting for any dup=
licate ACK ?
>> /proc/sys/net/ipv4/tcp_reordering =A0 - Please clarify.
>> The default value is 3 which means it waits until 3 duplicate ack's
>> arrive and then start retransmission.
>>
>> "The TCP sender should use the fast retransmit algorithm to detect a=
nd
>> repair loss based on incoming duplicate ACKs. After the arrival of 3
>> duplicate ACKs (4 identical ACKs without the arrival of any other
>> intervening packet), TCP performs a retransmission of what appears t=
o
>> be the missing segment, without waiting for the retransmission timer
>> to expire."
>
> Depends on other things quite much but for a typical transfer you'd s=
till
> need one duplicate ACK to trigger actual recovery. However, in genera=
l
> root is not (always) forbidden to set non-sensical values for sysctls=
=2E
>
> --
> =A0i.
>

Hmm....Is that mean setting the value as 0 is non-sensical ?

OR

After setting the value as 0,  TCP Stack doesn't expect any drops to
occur, so that there won't be any recovery required and if any drops
occur it leads to chaos from application point of view as it expects
all the packets  ...correct?


Actually I set the value as 0 and tried running firefox with few URLs
=2E..but my machine Crashed !
I think this is expected as This lead to chaos in the stack...
But If the same  value is tried between two machines connected
together directly  running iperf , There wont be any issues.


Thx,
Kavi
