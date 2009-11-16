From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH v6 4/7 RFC] TCPCT part 1d: define TCP cookie
 option, extend existing struct's
Date: Mon, 16 Nov 2009 23:26:04 +0100
Message-ID: <4B01D17C.4010407@gmail.com>
References: <4AFCDA9E.8050003@gmail.com> <4AFCE65C.2010104@gmail.com> <4AFCFD86.6020504@gmail.com> <4AFD8421.6090003@gmail.com> <4B01BB33.7080702@gmail.com> <4B01BF65.1010203@gmail.com> <4B01CD8D.1000305@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39977 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754240AbZKPW0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 17:26:04 -0500
In-Reply-To: <4B01CD8D.1000305@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson a =E9crit :
> Eric Dumazet wrote:
>> I am a bit uneasy on this patch, since apparently you have infrastru=
cture
>> to send DATA payload on SYN, but I thought it was an optional part o=
f
>> your 'RFC'
>> and as such, being implemented later ?
>>
> There is nothing yet in this patch series to send data with a SYN.  B=
ack in
> early October, David required that the various s_data and cookie stru=
ctures
> be compressed and consolidated.  So, for the client side, the cookie_=
*
> fields are filled and the s_data_* fields are zero (ignored), while t=
he
> server side can have both filled.
>=20
> Moreover, *this* patch does nothing other than allocate and deallocat=
e the
> structure, zero filled by kzalloc().
>=20
> SYN data will be implemented (much) later.

okay

>=20
>=20
>> I remember a previous remark from David that our skb queues would no=
t
>> contain
>> DATA on SYN packets...
>>
> I haven't seen anything by David, but there's an existing comment in
> tcp_input.c at the place where SYN data will be added later:
>=20

Yep, David comment was about another netdev thread, while tracking an o=
bscure bug

http://www.spinics.net/lists/netdev/msg110759.html

http://www.spinics.net/lists/netdev/msg110764.html


So adding DATA to SYN packets might be problematic for part of our tcp =
stack.

