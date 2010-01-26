From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: Network QoS support in applications
Date: Tue, 26 Jan 2010 15:43:01 +0100
Message-ID: <39575e70388bb2ea58dd36b9061d5055@chewa.net>
References: <877hr5nkx0.fsf@purkki.valot.fi> <20100126.041610.226004766.davem@davemloft.net> <87wrz5m3cd.fsf@purkki.valot.fi> <20100126.050645.184040277.davem@davemloft.net> <87my01m0zm.fsf@purkki.valot.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:41258 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751544Ab0AZOnF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2010 09:43:05 -0500
In-Reply-To: <87my01m0zm.fsf@purkki.valot.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 26 Jan 2010 15:47:41 +0200, Kalle Valo <kalle.valo@iki.fi> wrot=
e:=0D
> But that's just because of mistakes with DiffServ and other QoS=0D
> "frameworks". They didn't bother to specify how applications should=0D
> use these. And what matters here IMHO.=0D
=0D
TOS lets the application specify whether they want low-delay (interacti=
ve=0D
low bandwidth traffic), high bandwidth (bulk traffic), high reliability=
 or=0D
low cost. It's surely vague, but anything "uniform" solution is bound t=
o be=0D
vague. Some applications *do* set those fields, or provide options to s=
et=0D
them up. And contrary to SO_PRIORITY, it *can* be made to work for=0D
non-local queues, if the applications are trusted.=0D
=0D
I am afraid it's too late for anything more uniform at the socket API=0D
level. Even fewer developers would bother to support Linux>=3D2.6.3x-sp=
ecific=0D
options, than TOS/TCLASS.=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net=0D
http://fi.linkedin.com/in/remidenis

