From: =?UTF-8?B?QW7DrWJhbCBBbG1laWRhIFBpbnRv?= <anibal.pinto@efacec.com>
Subject: Re: Gianfar ethernet drop package
Date: Mon, 27 Aug 2012 11:32:27 +0100
Message-ID: <503B4CBB.1020405@efacec.com>
References: <5037A86E.2000004@efacec.com> <1345832223.19483.75.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.efacec.com ([62.28.144.243]:27421 "HELO mail2.efacec.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751632Ab2H0Kcj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2012 06:32:39 -0400
In-Reply-To: <1345832223.19483.75.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 24-08-2012 19:17, Eric Dumazet escreveu:
> On Fri, 2012-08-24 at 17:14 +0100, An=C3=ADbal Almeida Pinto wrote:
>> Hi,
>>
>> I have an board with a ppc with a 8379, kernel 3.0.39 and with a Gia=
nfar
>> Ethernet Controller Version 1.2.
>>
>> When connect the board to office network the number of dropped packe=
ts
>> reported by ifconfig continues to increase.
>>
>> Following the test made at [1] I use tcpdump and when running it the
>> number of drop packages don't have increased.
>>
>> When executing ethtool eth0 -S it return a rx-dropped-by-kernel !=3D=
 0.
>> And the rest of drop packages
>>
>> Is possible to get info why the packages are dropped?
>
> You receive frames for unknown protocols. So they are dropped.
>
> When running tcpdump, your tcpdump get them, they are not dropped.
>
> So just parse your tcpdump output ?
>

I generate the log on the board with tcpdump -i eth0 -w log_eth0.txt an=
d=20
loaded the result on wireshark (on other pc).

On the wireshark everything appears to be fine don't have nothing that=20
indicate the protocol isn't supported.

On /etc/protocols is a list with protocols, it there is a place where=20
exist a place with protocols supported by kernel ?

Thanks
