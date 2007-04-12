From: Milan =?ISO-8859-1?Q?Koci=E1n?= <milon@wq.cz>
Subject: Re: [Bugme-new] [Bug 8320] New: replacing route in kernel doesn't
	send netlink message
Date: Thu, 12 Apr 2007 19:53:48 +0200
Message-ID: <1176400428.24446.40.camel@nt.wq.cz>
References: <200704110937.l3B9b1Kp001053@fire-2.osdl.org>
	 <20070411094740.e7c04b49.akpm@linux-foundation.org>
	 <461D26CB.3010508@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wq.cz ([82.202.95.52]:35081 "EHLO rd.wq.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030658AbXDLSYb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2007 14:24:31 -0400
In-Reply-To: <461D26CB.3010508@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-04-11 at 20:19 +0200, Patrick McHardy wrote:

>=20
> I think having notifications for this case makes sense (IIRC I used
> to use a similar patch some time ago, but can't find it right now).
> But we need to indicate somehow that it is a replacement and not a
> completely new route, either by sending a RTM_DELROUTE for the old
> route first (which would match what devinet does for addresses)
> or by echoing the NLM_F_REPLACE flag. The former would probably be
> easier for userspace to understand since it wouldn't need to
> replicate the replacement logic just to find out which rule got
> replaced.
>=20
>=20

Hard to tell what is better. I slightly tried to test my patch with
quagga routing daemon. And then I tested second case: send RTM_DELROUTE
before RTM_NEWROUTE. Quagga updates internal rib in both cases (as I sa=
w
in debug logs). I was in fear that quagga will try to install sefl rout=
e
but it doesn't catch.
So from my point of view is all the same :).

--=20
Milan Koci=E1n <milon@wq.cz>

