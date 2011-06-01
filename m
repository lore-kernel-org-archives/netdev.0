From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Skipping past TCP lost packet in userspace
Date: Wed, 01 Jun 2011 10:35:23 -0700
Message-ID: <1306949723.8149.2202.camel@tardy>
References: <4DE44218.4070306@krellan.com>
	 <BANLkTinKORbHHZ7dAqfiFOg5rqB77DcJY8D7AxmP-xwhwmOgGg@mail.gmail.com>
	 <4DE5F3E3.2080609@krellan.com>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>, netdev <netdev@vger.kernel.org>,
	jiyengar@fandm.edu
To: Josh Lehan <linux@krellan.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:23853 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752037Ab1FARoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 13:44:06 -0400
In-Reply-To: <4DE5F3E3.2080609@krellan.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-06-01 at 01:10 -0700, Josh Lehan wrote:
> On 05/31/2011 10:23 AM, Yuchung Cheng wrote:
> > This paper may have a solution to your problem
> > "Minion=E2=80=94an All-Terrain Packet Packhorse to Jump-Start Stall=
ed Internet
> > Transports"
> > http://csweb1.fandm.edu/jiyengar/lair/papers/minion-pfldnet2010.pdf
>=20
> Nice, thanks for pointing me to this.  I appreciate the helpful answe=
r,
> instead of just saying "use UDP" or "use SCTP".  That's not the point=
=2E
>=20
> For better or for worse, TCP is realistically the only viable protoco=
l
> for streaming to the largest possible audience these days, hence my
> question about adding this feature to the Linux TCP implementation.

Isn't that treating the symptoms of problems at layers 8 and 9 (*) with
kludges (perhaps hacks if one is feeling charitable) at the user
interface to layer 4?  Just how many more little bits can we add to the
great pile before the aroma is overpowering?  Or to abuse another
metaphor, is there really any camel's back left here?

And while Linux has had some slightly non-trivial, non-portable
enhancements to its interface to a TCP endpoint (TCP_CORK is something
that comes to mind) I don't think any of them have been anywhere nearly
as large a change to a fundamental semantic of a TCP connection as what
you propose.

rick jones

*
http://www.isc.org/store/logoware-clothing/isc-9-layer-osi-model-cotton=
-t-shirt


