From: Stas Sergeev <stsp@list.ru>
Subject: Re: Q: bad routing table cache entries
Date: Tue, 29 Dec 2015 20:40:34 +0300
Message-ID: <5682C592.5070106@list.ru>
References: <5682665A.7090102@list.ru> <20151229152208.GA22423@oracle.com>
 <5682A8D8.5040403@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp40.i.mail.ru ([94.100.177.100]:51420 "EHLO smtp40.i.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753476AbbL2Rkk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Dec 2015 12:40:40 -0500
In-Reply-To: <5682A8D8.5040403@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

29.12.2015 18:38, Stas Sergeev =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Likely the router's side is doing the right thing, but of
Or maybe not?
Here's the ifconfig of router:

eth0      Link encap:Ethernet  HWaddr 00:1e:8c:a7:b5:36
          inet addr:192.168.0.220  Bcast:192.168.3.255  Mask:255.255.25=
2.0

eth0:1    Link encap:Ethernet  HWaddr 00:1e:8c:a7:b5:36
          inet addr:192.168.8.1  Bcast:192.168.11.255  Mask:255.255.252=
=2E0


# route
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use=
 Iface
default         192.168.0.1     0.0.0.0         UG    0      0        0=
 eth0
10.1.10.0       192.168.10.143  255.255.255.0   UG    0      0        0=
 eth0
localnet        *               255.255.252.0   U     0      0        0=
 eth0
192.168.8.0     *               255.255.252.0   U     0      0        0=
 eth0


Masks look correct.
So why would it send redirects to hosts of 192.168.8.0 subnet
with the gateway of 192.168.0.0 subnet?
