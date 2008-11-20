From: =?ISO-8859-1?Q?Roar_Bj=F8rgum_Rotvik?= <roarbr@tihlde.org>
Subject: Re: Is there any function similar to inet_ntoa() in Kernel or NetFilter
 ?
Date: Thu, 20 Nov 2008 10:34:18 +0100
Message-ID: <49252F1A.4060304@tihlde.org>
References: <192580.22596.qm@web111104.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: linux_kernel_chan@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail49.e.nsc.no ([193.213.115.49]:49264 "EHLO mail49.e.nsc.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753618AbYKTK0E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2008 05:26:04 -0500
In-Reply-To: <192580.22596.qm@web111104.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kunsheng Chen wrote:
> Hello, everyone,
>=20
> I am doing a project similar to iptable using netfilter, currently I =
want to convert a IP address from 'long int' back to dotted address.
>=20
> I don't know whether there is some functions inside kernel or netfilt=
er that could make that like using inet_ntoa() in <arpa/inet.h>

How about NIPQUAD and NIPQUAD_FMT (for IPv4):
http://lxr.linux.no/linux+v2.6.27.6/include/linux/kernel.h#L324
http://lxr.linux.no/linux+v2.6.27.6/include/linux/kernel.h#L319

Example on how to use:
http://lxr.linux.no/linux+v2.6.27.6/net/ipv4/ipconfig.c#L1184

printk("my address is " NIPQUAD_FMT "\n", NIPQUAD(ic_myaddr));

--=20
Roar Bj=F8rgum Rotvik

