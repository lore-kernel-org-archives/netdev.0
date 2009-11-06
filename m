From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] netlink: add socket destruction notification
Date: Fri, 06 Nov 2009 16:26:44 +0100
Message-ID: <1257521204.29454.31.camel@johannes.local>
References: <1254473048.3959.76.camel@johannes.local>
	 <4AF43EF9.3020707@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-CWNVZF+VtLJf2T9o1Dyq"
Cc: netdev <netdev@vger.kernel.org>, Jouni Malinen <j@w1.fi>,
	Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:37470 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759351AbZKFP0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 10:26:49 -0500
In-Reply-To: <4AF43EF9.3020707@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-CWNVZF+VtLJf2T9o1Dyq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2009-11-06 at 16:21 +0100, Patrick McHardy wrote:
> Johannes Berg wrote:
> > When we want to keep track of resources associated with applications, w=
e
> > need to know when an app is going away. Add a notification function to
> > netlink that tells us that, and also hook it up to generic netlink so
> > generic netlink can notify the families. Due to the way generic netlink
> > works though, we need to notify all families and they have to sort out
> > whatever resources some commands associated with the socket themselves.


> This seems pretty similar to the NETLINK_URELEASE notifier invoked
> in netlink_release(). Wouldn't that one work as well?

Hmm, it does seem similar, thanks for pointing it out. What exactly does
the condition
	if (nlk->pid && !nlk->subscriptions) {

mean though?

johannes


--=-CWNVZF+VtLJf2T9o1Dyq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJK9EAtAAoJEODzc/N7+QmaXfMP/2oJAyBFRmqWxhVWunu8nj8T
NENyQs5yNzsEUdVoUBzQmFrQdT9Zdhim2FU2p0r+PH0TtpsSFNxVyJmgXKeKVx94
neIiBHgr/btMRPU8beNICwXuzCONclxbjN0xQyiK7CaRcfE0p+B1ldGAEzHmQAWE
yokm3cR1FmjZWJvuYy9DUGMr6b4RCmyM86kwmP7VD3Is7AcQUNtDq5jVoCEROoe1
lfS7wc/fLw50teq3ywRVcvoqxqabDBHnKDXLA3/VmInKc5Tgli6hclERcz4ZHH10
US5yoDxiQ4rE1fR7VGm/Pqj5ZOSbk99XePMC9OS/CL2wMB3jaFw21vWjQyf4HtU4
ita0RWrFalk3WLFJQHXFuan6+MMGh4SlTA3tsqvoMZXXkfQ+c8vcsoY4kxXu3IeO
Di3sHjEZaBIW7LvRnOdZCRuK6lcyLENGlb9rR3YJC5Anu2tXTUCgFRIBj8VngnT3
Wo1B6YDuUAL3/jblL/E7H9dE+yKFcQGkjkA708cxcZwzrT718ZCEuBlLKDpuFfKu
/5QYb/HeU0iRRldsJ7KE9z0Wo5wLdeBD30AltAibhi2PhZVNdVyluqfcrS4hJSQn
49AwpZq8ZiEmbObG2kQQdwe40qKq+9HReQ0sjGUoqpzupbRwkAve3uVbQHrFn9Qn
2vKflwG8rt4HJWPIdfww
=FYjr
-----END PGP SIGNATURE-----

--=-CWNVZF+VtLJf2T9o1Dyq--

