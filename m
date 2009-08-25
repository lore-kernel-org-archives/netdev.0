From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Tue, 25 Aug 2009 17:32:00 +0200
Message-ID: <4A9403F0.2060301@gmail.com>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>  <4A89C026.4030402@us.ibm.com>  <alpine.DEB.1.10.0908171642500.20399@gentwo.org>  <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171813070.15956@gentwo.org>  <1250549034.25939.30.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171848370.15956@gentwo.org> <1250554332.25939.46.camel@w-sridhar.beaverton.ibm.com> <alpine.DEB.1.10.0908241334230.30487@gentwo.org> <4A930DEF.5000008@gmail.com> <alpine.DEB.1.10.0908250945460.5972@gentwo.org> <4A93EB9B.5020600@gmail.com> <alpine.DEB.1.10.0908250958540.28552@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48015 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690AbZHYPcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 11:32:47 -0400
In-Reply-To: <alpine.DEB.1.10.0908250958540.28552@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Tue, 25 Aug 2009, Eric Dumazet wrote:
>=20
>> Please hold on, I would like to fully understand what's happening,
>> and test the patch :)
>=20
> Ok. It would be good if the drops would also be somehow noted by the =
UDP
> subsystem (one should see something with netstat -su) and may be even=
 the
> socket. I see a drops column in /proc/net/udp. rx_drops, tx_drops?

This /proc/net/udp column is for rx_drops currently and was recently ad=
ded...
