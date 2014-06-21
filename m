From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/1] net/dsa/dsa.c: remove null test before kfree
Date: Sat, 21 Jun 2014 07:10:06 -0700
Message-ID: <1403359806.4076.50.camel@joe-AO725>
References: <1403296607-6065-1-git-send-email-fabf@skynet.be>
	 <b991e868-c253-4b1a-8c95-56106c36d512@email.android.com>
	 <20140621113653.6b2dd148b35a6ecfb7c08cce@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@linaro.org>, netdev@vger.kernel.org
To: Fabian Frederick <fabf@skynet.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0019.hostedemail.com ([216.40.44.19]:58252 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752173AbaFUOKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2014 10:10:10 -0400
In-Reply-To: <20140621113653.6b2dd148b35a6ecfb7c08cce@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-06-21 at 11:36 +0200, Fabian Frederick wrote:
> On Sat, 21 Jun 2014 10:37:24 +0200 Bj=F8rn Mork <bjorn@mork.no> wrote=
:
> > On 20 June 2014 22:36:47 CEST, Fabian Frederick <fabf@skynet.be> wr=
ote:
> > > Fix checkpatch warning:
> > > WARNING: kfree(NULL) is safe this check is probably not required
> >=20
> > "probably not" implies that there are cases where the check *is*
> > required.  That means that your commit message should explain why
> > this particular check is redundant.
> >=20
> > I haven't analyzed your changes here, so they could be fine for all
> > I know. My point is that such analysis is your job when submitting
> > cleanups like this one.
> AFAIK, any
>=20
> if(foo)
> 	kfree(foo)
> =09
> can be updated to kfree(foo) but
>=20
> if (foo){
> 	kfree(foo)
> 	do something else
> }
>=20
> has to be evaluated ; reason for the "probably" in warning message.
> If I'm wrong maybe we could be more verbose in checkpatch :)

I think Bj=F8rn is correct here.

Just because checkpatch bleats some message or another,
it's still the submitter's job to validate the code.

In this case, it seems the simple substitution of
"unnecessary null" to the subject would have been
enough validation.

I don't think checkpatch needs updating for this, but
maybe you could propose better language.
