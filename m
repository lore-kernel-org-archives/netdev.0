From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] OpenBSD Networking-related randomization port
Date: Fri, 28 Jan 2005 12:45:17 -0800
Message-ID: <20050128124517.36aa5e05.davem@davemloft.net>
References: <1106932637.3778.92.camel@localhost.localdomain>
	<20050128100229.5c0e4ea1@dxpl.pdx.osdl.net>
	<1106937110.3864.5.camel@localhost.localdomain>
	<20050128105217.1dc5ef42@dxpl.pdx.osdl.net>
	<1106944492.3864.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: shemminger@osdl.org, linux-kernel@vger.kernel.org, chrisw@osdl.org,
        netdev@oss.sgi.com, arjan@infradead.org, hlein@progressive-comp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lorenzo =?ISO-8859-1?Q?Hern=E1ndez_Garc=EDa-Hierro?= <lorenzo@gnu.org>
In-Reply-To: <1106944492.3864.30.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 28 Jan 2005 21:34:52 +0100
Lorenzo Hern=E1ndez Garc=EDa-Hierro <lorenzo@gnu.org> wrote:

> Attached the new patch following Arjan's recommendations.

No SMP protection on the SBOX, better look into that.
The locking you'll likely need to add will make this
routine serialize many networking operations which is
one thing we've been trying to avoid.
