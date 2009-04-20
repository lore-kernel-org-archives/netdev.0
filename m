From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: Porting the ibm_newemac driver to use phylib (and other PHY/MAC
	questions)
Date: Mon, 20 Apr 2009 08:29:24 -0400
Message-ID: <625fc13d0904200529l152b8d75g33c3f940de1b2920@mail.gmail.com>
References: <f73f7ab80904171732n41832d0hc62978e57bbcc32e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: linuxppc-dev@ozlabs.org, netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>
To: Kyle Moffett <kyle@moffetthome.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <f73f7ab80904171732n41832d0hc62978e57bbcc32e@mail.gmail.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 17, 2009 at 8:32 PM, Kyle Moffett <kyle@moffetthome.net> wrote:
> Hello,
>
> I'm currently fiddling with a custom embedded prototype board using
> the ibm_newemac driver with some currently-unsupported PHYs. =A0Those
> PHYs *are* supported by phylib, but the emac driver seems to have its
> own PHY layer cribbed from the sungem driver. =A0I'm curious if there's
> some particular reason it hasn't been ported (aside from "nobody has
> bothered yet").

IIRC, Ben had some issues with how phylib and the EMAC would need to
interact.  Not sure if he has those written down somewhere or not.
(CC'd).

> I've temporarily hacked a PHY driver together for the moment, but it
> would be much easier for us to maintain and update our board if the
> PHY drivers were integrated. =A0As a result I'm also interested in how
> complicated it might be to port the driver (and possibly sungem as
> well) over to phylib, if that is indeed feasible. =A0Also, if I end up
> going that route, are there others available with other hardware
> variants who would be willing to test my patches on their boards?

I have a large variety of boards that I can test with since the entire
4xx line relies on this driver for on-board network.

josh
