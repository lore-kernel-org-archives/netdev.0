From: =?UTF-8?Q?Fl=c3=a1vio_Silveira?= <fggs@terra.com.br>
Subject: Re: Attansic L1 driver issue
Date: Tue, 12 Jan 2016 13:13:03 -0200
Message-ID: <569517FF.6060602@terra.com.br>
References: <56876713.9090100@terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, Chris Snook <chris.snook@gmail.com>,
	jcliburn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from if01-mail-sr09-mia.mta.terra.com ([208.84.243.26]:54429 "EHLO
	if01-mail-sr09-mia.mta.terra.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753124AbcALPNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 10:13:10 -0500
In-Reply-To: <56876713.9090100@terra.com.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/01/2016 03:58, Fl=C3=A1vio Silveira wrote:
> Good morning,
>
>   I'm investigating a possible issue with atl1 driver used by Attansi=
c=20
> L1.
>
>   During my tests with iperf3 I saw a performance drop when the=20
> computer is client.
>
>   I can hit only about 580~600Mbit/s, if I disable=20
> generic-segmentation-offload (GSO) I can hit 660~670Mbit/s.
>
>   When the computer is server, I can hit 940~950Mbit/s.

Hi,

   I'm continuing to investigate this, tried older kernels (2.6.32 and=20
3.2.68) in order to see if it was a regression.

   What I discovered so far is that if I disable scatter-gather I can=20
see around 70Mbit/s of improvement, I wonder if there is anything else =
I=20
can do to understand the "tx busy" message I mentioned in first mail or=
=20
the issue itself.

Regards,
   Flavio
