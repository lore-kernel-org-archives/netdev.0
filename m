From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont" <rdenis@simphalempin.com>
Subject: Re: [PATCH] add a sysctl to disable TCP simultaneous connection opening
Date: Fri, 10 Oct 2008 11:44:06 +0300
Message-ID: <200810101144.06869.rdenis@simphalempin.com>
References: <20081008081109.GA25342@1wt.eu> <200810101059.25904.rdenis@simphalempin.com> <20081010081022.GA27187@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: "ext Willy Tarreau" <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:42976 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751385AbYJJIoM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 04:44:12 -0400
In-Reply-To: <20081010081022.GA27187@1wt.eu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 10 October 2008 11:10:22 ext Willy Tarreau, you wrote:
> > Duh? If you require a SYN from the outside to the server, before yo=
u
> > allow the server to send either SYN or SYN/ACK, I fail to see the
> > problem.
>
> Requiring the firewall to expect a first SYN to come from the interne=
t is
> like doing no check at all.

On ports which are open to the outside you MUST allow inbound SYNs anyw=
ay.=20
=46rom a security perspective, it does not matter whether the server an=
swers=20
with a SYN/ACK as normally or with a SYN-not-ACK as in "simultaneous op=
en".

On ports which the server is using outbound only (if any), you can expe=
ct the=20
server to send a SYN out first. It again does not matter whether the ot=
her=20
end answers with a SYN/ACK or a SYN-not-ACK.

On other ports, a plain dumb stateless blackhole will do.

> When your server has been rooted, you can=20
> pretty much expect that your guest has no problem sending you a SYN.

And why would (s)he have problem sending a SYN/ACK? It makes no differe=
nce.

--=20
R=E9mi Denis-Courmont
