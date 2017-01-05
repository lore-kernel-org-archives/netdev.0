From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v4 0/2] Add support for the ethernet switch on
 the ESPRESSObin
Date: Thu, 5 Jan 2017 15:52:25 +0100
Message-ID: <20170105145225.GI4229@lunn.ch>
References: <20161221125734.1034-1-romain.perier@free-electrons.com>
 <87tw9dbn2m.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Florian Fainelli <f.fainelli@gmail.com>,
 Romain Perier <romain.perier@free-electrons.com>,
 Jason Cooper <jason@lakedaemon.net>, Pawel Moll <pawel.moll@arm.com>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>, netdev@vger.kernel.org,
 Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Nadav Haklai <nadavh@marvell.com>, Rob Herring <robh+dt@kernel.org>,
 Kumar Gala <galak@codeaurora.org>, David Miller <davem@redhat.com>,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <87tw9dbn2m.fsf@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 05, 2017 at 03:25:53PM +0100, Gregory CLEMENT wrote:
> Hi David,
>  =

>  On mer., d=E9c. 21 2016, Romain Perier <romain.perier@free-electrons.com=
> wrote:
> =

> > This set of patches adds support for the Marvell ethernet switch 88E634=
1.
> > It also add the devicetree definition of this switch to the DT board.
> =

> The forth version of this series had been sent while the net-next merge
> window was closed so I think it was missed.

Having done a bit more research, i'm pretty sure the second patch is
wrong. The 88E6341 is not compatible with the 6352, it is a different
family. It might be more like the 6390. So supporting it will need a
side-by-side comparison of the datasheet against the 6352 and the
6390, and the correct selection of the ops.

      Andrew
