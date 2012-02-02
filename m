From: Michal Soltys <soltys@ziu.info>
Subject: Re: VLAN 1 - Native
Date: Thu, 02 Feb 2012 13:17:17 +0100
Message-ID: <4F2A7ECD.2050909@ziu.info>
References: <1328095366.10975.YahooMailNeo@web29004.mail.ird.yahoo.com>  <1328095449.75127.YahooMailNeo@web29014.mail.ird.yahoo.com>  <1328101484.2595.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <CADDf=MQ8EYEtOO2e5NJLrW0DKDz5xCBEBwuY6rxNu4Cybq=kKQ@mail.gmail.com>  <CADDf=MQ=0eadY-zT_YAgp17fo_xRUh0dg6nHCLpNXcMQnUdyCQ@mail.gmail.com>  <1328108723.2595.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <CADDf=MRDa6C47ToCnR3_cTkfJR8VL9UAScwzwGVUDn3O4nL6fA@mail.gmail.com>  <1328114680.76107.YahooMailNeo@web29019.mail.ird.yahoo.com>  <4F2991FD.8090407@ziu.info>  <1328173741.73927.YahooMailNeo@web29018.mail.ird.yahoo.com> <1328173972.2279.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Leonardo Uzcudun <uzcudunl@yahoo.it>,
	yao zhao <yao.development@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tha.ppgk.com.pl ([77.252.116.179]:24796 "EHLO tha.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756037Ab2BBM1K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Feb 2012 07:27:10 -0500
In-Reply-To: <1328173972.2279.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02.02.2012 10:12, Eric Dumazet wrote:
> Le jeudi 02 f=C3=A9vrier 2012 =C3=A0 09:09 +0000, Leonardo Uzcudun a =
=C3=A9crit :
>> Hello Michal:
>>
>> It is working on kernel 3.0.0-15 Ubuntu. I've just to modify the
>> ebtables command as:
>> ebtables -t broute -A BROUTING -i eth0 -p 802_1Q --vlan-id 101 -j DR=
OP
>> (protocol is a must when you use --vlan-id)
>>
>>
>> I'll test it on kernel 2.6.32-5 Debian
>>
>>
>> Just last question,in the case i should implement this kind of
>> configuration in a kernel 2.6.31, should i backport/patch anything? =
is
>> it a bad idea (running it on 2.6.31)?
>
> This is going to be tough.
>

Btw, this (ebtables broute drop) method has been mentioned in bridge-nf=
=20
faq for ages (through most/all 2.6 kernels at least) - and for the very=
=20
purpose of directing tagged/not tagged traffic to proper bridge=20
interfaces. Shouldn't 2.6.31 be pretty safe in that regard ?

Or did you mean backporting/patching part ?

> The point of Jesse Gross (and others) work was exactly to permit bett=
er
> vlan/bridge integration/stacking.
>

Just to be sure - are those patches in any way changing / deprecating /=
=20
conflicting with ebtables approach ?
