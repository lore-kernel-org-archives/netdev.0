From: John Heffner <johnwheffner@gmail.com>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Tue, 10 Mar 2009 08:23:34 -0700
Message-ID: <1e41a3230903100823h5d5768d9wb9f36eb294840814@mail.gmail.com>
References: <20090309195906.M50328@bts.sk>
	 <1e41a3230903091323j541d1895j2eb69b9f9c11f2f3@mail.gmail.com>
	 <20090310104956.GA81181@bts.sk>
	 <20090310.043019.132650585.davem@davemloft.net>
	 <20090310114606.GA84964@bts.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?ISO-8859-2?Q?Marian_=CFurkovi=E8?= <md@bts.sk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:58689 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756599AbZCJPXh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 11:23:37 -0400
Received: by yx-out-2324.google.com with SMTP id 8so1493722yxm.1
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2009 08:23:35 -0700 (PDT)
In-Reply-To: <20090310114606.GA84964@bts.sk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2009 at 4:46 AM, Marian =CFurkovi=E8 <md@bts.sk> wrote:
> On Tue, Mar 10, 2009 at 04:30:19AM -0700, David Miller wrote:
>> From: Marian =CFurkovi=E8 <md@bts.sk>
>> Date: Tue, 10 Mar 2009 11:49:56 +0100
>>
>> > Sender does not have the relevant info to implement this - it migh=
t be
>> > connected by 10 GE to the highspeed backbone.
>>
>> Yes, the sender does indeed have this information, and using it is
>> exactly what congestion control algorithms such as VEGAS try to do.
>>
>> They look at both round trip times and bandwith as they increase the
>> send congestion window. =A0And if round trips increase without a
>> corresponding increase in bandwidth, they stop increasing.
>
> Yes, but that's actual bandwidth between sender and receiver, not
> the hard BW limit of the receiver's NIC. My intention is just to intr=
oduce
> some safety belt preventing autotuning to increase the rx window
> into MB ranges when RTT is very low.

Nowhere in our proposal do you use NIC bandwidth.  What you proposed
can be done easily at the sender.

  -John
