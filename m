From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: Bonding
Date: Tue, 11 Feb 2014 15:15:49 +0100
Message-ID: <20140211141549.GB29570@redhat.com>
References: <8532C3BD1ECBC64BA47CE43AFED6D38EC37E5AA5@S103.efacec.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Gustavo Pimentel <gustavo.pimentel@efacec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45544 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751071AbaBKOQL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Feb 2014 09:16:11 -0500
Content-Disposition: inline
In-Reply-To: <8532C3BD1ECBC64BA47CE43AFED6D38EC37E5AA5@S103.efacec.pt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 11, 2014 at 01:53:32PM +0000, Gustavo Pimentel wrote:
>Hi,

Hi Gustavo,

>
>I'm writing you because because I'm have implemented a new mode (PRP P=
arallel Redundancy Protocol) for bonding kernel driver. This new mode i=
s quite simple, I don't know if you have heard about PRP, but it's a ne=
w standard that allows to overcome any single network failure without a=
ffecting the data transmission. The general idea resides on having two =
separate LAN (A & B) very similar and transmitting the almost the same =
frame=A0through both LANs and the end device should accept one frame an=
d discard the other according to a known mechanism.

Isn't that the current 'broadcast' mode, where every packet is transmit=
ted
over all the slaves? After quick googling/reading I don't see any
difference there, though I might have missed something.

>
>I have implemented this new mode on bonding driver, but I have some di=
fficulties:
>. Writing linux driver is quite new for me. I don't' know if exists gu=
ide lines for driver coding.

You can find everything under Documentation/, but without the code I ca=
n't
tell you exact documents. CodingStyle and SubmittingPatches might be th=
e
first ones.

Also, try CC-ing relevant people for more feedback, specifically bondin=
g
maintainers.

>. I don't know how to submit the code to be include on kernel reposito=
ry.
>. Maybe another pair of eyes could find help to improve the writing co=
de for this mode.

Try sending an RFC when net-next opens.

>
>I think my driver code is 99% complete. I'm currently testing with 3 e=
quipments (1 pc + 1 embedded device running both my modify bonding driv=
er) and a third party equipment called RedBox.
>
>Would you be interested in participating / helping this project?
>
>With my best regards,
>
>Gustavo Gama da Rocha Pimentel
>Power Systems Automation / Innovation & Development
>Efacec Engenharia e Sistemas, S.A.
>Phone: +351229403391
>Disclaimer
>
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
