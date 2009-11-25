From: linuxpark <linuxpark@gmail.com>
Subject: Re: [tproxy] [HELP] Tproxy server Can't receive any client packet
Date: Wed, 25 Nov 2009 17:54:30 +0900
Message-ID: <4B0CF0C6.8040808@gmail.com>
References: <d5cf4b4f0911222251u1589c66ar78810d5b9d87cb5e@mail.gmail.com> <1259137840.9191.7.camel@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tproxy@lists.balabit.hu, netfilter-announce@lists.netfilter.org,
	netfilter@lists.netfilter.org, netdev@vger.kernel.org,
	rnd@elim.net, dylee@elim.net
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:38234 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319AbZKYIyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 03:54:31 -0500
Received: by pwi3 with SMTP id 3so4741673pwi.21
        for <netdev@vger.kernel.org>; Wed, 25 Nov 2009 00:54:37 -0800 (PST)
In-Reply-To: <1259137840.9191.7.camel@nienna.balabit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks your reply ~

i succeed in tproxy function of the apache server
--
kernel 2.6.31 (vannilla kernel)
iptables 1.4.3   (no patched)
apache 2.2.9 + patches (main socket routine of the apache, mod_tproxy.c=
)

--



KOVACS Krisztian =EC=93=B4 =EA=B8=80:
> Hi,
>
> On Mon, 2009-11-23 at 15:51 +0900, =EB=B0=95=EC=A0=9C=ED=98=B8 wrote:
>  =20
>> i have a problem in my transparent proxy test,
>> i recently made up the testbed as below to run the tproxy patched
>> apache proxy [mod_proxy],
>> and i applied all iptables and routing rules with referencing the
>> readme file [http://www.balabit.com/downloads/files/tproxy/README.tx=
t,
>> http://www.mjmwired.net/kernel/Documentation/networking/tproxy.txt]
>> the proxy server listening the port 3128 and i checked there were no=
 problem.
>> but  when the client tried to connect the web server,
>> the packets reached to the box and i found the usage counts of filte=
r
>> rules in the mangle table incresed
>> but my tproxy server could not receive any corresponding packet from=
 the socket
>>
>> I want to know why my proxy server can't receive any packet through =
the socket,
>> Do i need some more DNAT rules ?
>>    =20
>
> Would you mind testing the setup with an unpatched upstream kernel, t=
hat
> has tproxy built-in? (2.6.31, for example)
>
> Also, please download the latest iptables from netfilter.org and try
> using that. (No need for patching, tproxy support is in upstream.)
>
> That would help a lot in identifying the source of the issue. Thanks =
in
> advance.
>
> Cheers,
> Krisztian
>
>
>  =20

