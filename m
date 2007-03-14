From: Alex Sidorenko <alexandre.sidorenko@hp.com>
Subject: Re: SWS for rcvbuf < MTU
Date: Wed, 14 Mar 2007 12:18:56 -0400
Message-ID: <200703141218.57179.alexandre.sidorenko@hp.com>
References: <200703021521.58821.alexandre.sidorenko@hp.com> <200703051152.27780.alexandre.sidorenko@hp.com> <45F6F51E.6090905@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:36119 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932339AbXCNQSo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2007 12:18:44 -0400
In-Reply-To: <45F6F51E.6090905@psc.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On March 13, 2007 03:01:50 pm John Heffner wrote:
> Sorry for the long delay in response, I've been on vacation. =A0I'm o=
kay
> with your patch, and I can't think of any real problem with it, excep=
t
> that the behavior is non-standard. =A0Then again, Linux acking in gen=
eral
> is non-standard, which has created the bug in the first place. :) =A0=
The
> only thing I can think where it might still ack too often is if
> free_space frequently drops just below full_space/2 for a bit then ri=
ses
> above full_space/2.
>
> I've also attached a corrected version of my earlier patch that I thi=
nk
> solves the problem you noted.

Hello John,

I think your corrected version should avoid the problem I mentioned, bu=
t I=20
will still ask the customer to test the new version. It will be interes=
ting=20
to compare traffic patterns with those observed with stock kernel and m=
y=20
earlier patch.

It might take some time to do proper testing, I'll inform you as soon a=
s there=20
are any results.

Thanks,
Alex


--=20
------------------------------------------------------------------
Alexandre Sidorenko             email: alexs@hplinux.canada.hp.com
Global Solutions Engineering:   Unix Networking
Hewlett-Packard (Canada)
------------------------------------------------------------------
