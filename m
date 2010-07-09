From: =?ISO-8859-1?Q?Mart=EDn_Ferrari?= <martin.ferrari@gmail.com>
Subject: Re: Bug handling devices with weird names
Date: Fri, 9 Jul 2010 17:41:42 +0200
Message-ID: <AANLkTinGqQm_HaQABTwQes2D60D3smU2WrD5qydBvoOb@mail.gmail.com>
References: <AANLkTinBvzfdiAldJkXfH_vOkCv_cK7hBhjmH1l2vHTd@mail.gmail.com>
	<20100708102747.66d0ad78@s6510>
	<AANLkTim3IpnHn8ZedpYAphlA1ZdhzizuJo-azmPtd-kd@mail.gmail.com>
	<1278670779.2696.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:33073 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755970Ab0GIPlo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 11:41:44 -0400
Received: by fxm14 with SMTP id 14so1188223fxm.19
        for <netdev@vger.kernel.org>; Fri, 09 Jul 2010 08:41:42 -0700 (PDT)
In-Reply-To: <1278670779.2696.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Jul 9, 2010 at 12:19, Eric Dumazet <eric.dumazet@gmail.com> wro=
te:
> Update user land tools ?
>
> No problem here :
>
> # ip link add name foo: type dummy
> # ip link list foo:
> 14: foo:: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN
> =A0 =A0link/ether e6:48:a9:57:d4:1f brd ff:ff:ff:ff:ff:ff
> # ip link del foo:
> # ip -V
> ip utility, iproute2-ss100519

I am using the exact same version (from Debian), and I can also
reproduce it with fedora's iproute2-ss080725.
The kernels are 2.6.35-rc4 and 2.6.27, respectively.. Maybe your
version of iprout is patched as to not use ioctl?



--=20
Mart=EDn Ferrari
