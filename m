From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Configure ICMP error source address
Date: Fri, 8 Jan 2016 17:11:43 +0100
Message-ID: <568FDFBF.3010300@stressinduktion.org>
References: <568F8207.9040305@heinlein-support.de>
 <20160108152448.5251154.50977.21786@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: prmarino1@gmail.com, Robert Sander <r.sander@heinlein-support.de>,
	netfilter@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:51302 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932349AbcAHQLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 11:11:45 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id AEB4A20D4E
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 11:11:44 -0500 (EST)
In-Reply-To: <20160108152448.5251154.50977.21786@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08.01.2016 16:24, prmarino1@gmail.com wrote:
> Don't put a public address on a lo device use a dummy eth interface i=
nstead=E2=80=8E. Any IP address and it's subnet assigned to a lo device=
 is  marked as a marcian address and the traffic is dropped if it tries=
 to leave the lo device.

O_o

> I know that there is som old documentation out there (for example qua=
gga's documentation) that says you can do it =E2=80=8Ebut it's been wro=
ng since the 2.4 version off the kernel.
> Linux treats the lo device differently that what routers call a loopb=
ack device. The dummy driver is the linux equivalent of what routers ca=
ll a loopback device.

What you write seems odd to me, we don't treat lo devices differently t=
o=20
dummy devices in respect if you bind a public ip address on it.

Bye,
Hannes
