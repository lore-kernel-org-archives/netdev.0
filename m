From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29 (results with
 IRQ affinity)
Date: Sat, 18 Apr 2009 10:18:22 +0200
Message-ID: <49E98CCE.2000701@cosmosbay.com>
References: <49E78A79.6050604@cosmosbay.com> <49E78C1E.9060405@cosmosbay.com> <alpine.DEB.1.10.0904161555040.23632@qirst.com> <20090416.160002.09845606.davem@davemloft.net> <alpine.DEB.1.10.0904171238550.20049@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37247 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753358AbZDRITQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 04:19:16 -0400
In-Reply-To: <alpine.DEB.1.10.0904171238550.20049@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Thu, 16 Apr 2009, David Miller wrote:
>=20
>> We really need to find a good way to fix that IRQ affinity issue.
>=20
> Here are the results with setting interrupt affinity. We are still lo=
osing
> 5 usecs from .22 to .30-rc2. We will investigate more in depth time
> permitting.
>=20
> 	UDP ping pong 40 bytes
>=20
> Kernel		Test 1	Test 2	Test 3	Test 4	Avg
> 2.6.22		83.1125	83.4	83.03	82.95	83.07
> 2.6.23		83.33	83.51	83.18	83.42	83.21
> 2.6.24		82.7775	82.8	82.77	82.77	82.77
> 2.6.25		85.875	85.94	85.75	86.06	85.75
> 2.6.26		87.4025	87.53	87.25	87.3	87.53
> 2.6.27		87.81	87.81	87.77	87.82	87.84
> 2.6.28		87.4275	87.77	87.24	87.28	87.42
> 2.6.29		88.4325	88.48	88.42	88.44	88.39
> 2.6.30-rc2	88.4925	88.49	88.44	88.56	88.48


You are using UDP, and UDP got memory accounting. This=20

