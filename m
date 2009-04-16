From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29
Date: Thu, 16 Apr 2009 21:29:02 +0200
Message-ID: <49E786FE.6090304@cosmosbay.com>
References: <alpine.DEB.1.10.0904161151330.13531@qirst.com> <49E76906.2060205@hp.com> <alpine.DEB.1.10.0904161504090.15835@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56906 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755391AbZDPT3s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 15:29:48 -0400
In-Reply-To: <alpine.DEB.1.10.0904161504090.15835@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Thu, 16 Apr 2009, Rick Jones wrote:
>=20
>> Does udpping have a concept of service demand a la netperf?  That co=
uld help
>> show how much was code bloat vs say some tweak to interrupt coalesci=
ng
>> parameters in the NIC/driver.
>=20
> No. What does service on demand mean? The ping pong tests are very si=
mple
> back and forths without any streaming or overlay.
> --

Would be good to measure a ping flood, because this one doesnt
need wakeup of a user process on the remote side.


$ ping -f 192.168.20.112 -c 10000
PING 192.168.20.112 (192.168.20.112) 56(84) bytes of data.

--- 192.168.20.112 ping statistics ---
10000 packets transmitted, 10000 received, 0% packet loss, time 3337ms
rtt min/avg/max/mdev =3D 0.072/0.184/20.011/1.389 ms, pipe 2, ipg/ewma =
0.333/0.078 ms

and check if various kernel versions already give you different values =
(for avg)

When you perform your test, you upgrade kernels of both machines ?

