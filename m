From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Subject: Re: [PATCH NEXT 3/5] qlcnic: vlan lro support
Date: Fri, 17 Sep 2010 11:34:46 +0400
Message-ID: <381611284708887@web110.yandex.ru>
References: <1284642872-27832-1-git-send-email-amit.salecha@qlogic.com>
	 <1284642872-27832-4-git-send-email-amit.salecha@qlogic.com>
 <1284643638.3352.30.camel@edumazet-laptop> <99737F4847ED0A48AECC9F4A1974A4B80F86F8005A@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Amit Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward6.mail.yandex.net ([77.88.60.125]:49308 "EHLO
	forward6.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826Ab0IQHlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 03:41:12 -0400
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80F86F8005A@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



17.09.2010, 11:10, "Amit Salecha" <amit.salecha@qlogic.com>:
>> =C2=A0-----Original Message-----
>> =C2=A0From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
>> =C2=A0Sent: Thursday, September 16, 2010 6:57 PM
>> =C2=A0To: Amit Salecha
>> =C2=A0Cc: davem@davemloft.net; netdev@vger.kernel.org; Ameen Rahman;=
 Anirban
>> =C2=A0Chakraborty
>> =C2=A0Subject: Re: [PATCH NEXT 3/5] qlcnic: vlan lro support
>>
>> =C2=A0Le jeudi 16 septembre 2010 =C3=A0 06:14 -0700, Amit Kumar Sale=
cha a =C3=A9crit :
>>> =C2=A0LRO + GRO + vlan rx accleration support, performance increase=
s
>>> =C2=A0around 20% and cpu utilization reduces around 70% on vlan int=
erface.
>> =C2=A0Interesting. What is the workload that demonstrates such gains=
 ?
>
> Just to demonstrate decrease in cpu utilization further:
> I have taken numbers with various load. I used iperf application to r=
un tcp traffic on vlan interface.

> There is around 80-90% of reduction in cpu utilization.

I'm wondering, how can this scale further. For example if I have 200K l=
ow speed simultaneous
TCP connections (router appliance case with many users). Can GRO give u=
s some gain here?

--
wbr, Oleg.
