From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP regression with packets rates < 10k per sec
Date: Wed, 09 Sep 2009 19:08:10 +0200
Message-ID: <4AA7E0FA.5070005@gmail.com>
References: <alpine.DEB.1.10.0909081820030.7733@V090114053VZO-1> <4AA6E039.4000907@gmail.com> <alpine.DEB.1.10.0909091000200.28070@V090114053VZO-1> <4AA7C512.6040100@gmail.com> <alpine.DEB.1.10.0909091234360.15538@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58957 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373AbZIIRIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 13:08:10 -0400
In-Reply-To: <alpine.DEB.1.10.0909091234360.15538@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Wed, 9 Sep 2009, Eric Dumazet wrote:
>=20
>> Christoph Lameter a ?crit :
>>> On Wed, 9 Sep 2009, Eric Dumazet wrote:
>>>
>>>> In order to reproduce this here, could you tell me if you use
>>>>
>>>> Producer linux-2.6.22 -> Receiver 2.6.22
>>>> Producer linux-2.6.31 -> Receiver 2.6.31
>>> I use the above setup.
>> Then frames are sent on wire but not received
>>
>> (they are received via  mc loop, internal stack magic)
>=20
> We are talking about two machines running 2.6.22 or 2.6.31. There is =
no
> magic mc loop between the two machines. -L was not used.
>=20


I have no idea how you run the test then, and how are computed time del=
tas.

Are you clocks synchronized to less than one us ? How is it done ?
