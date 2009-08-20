From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] [V3] net: add Xilinx emac lite device driver
Date: Thu, 20 Aug 2009 11:44:32 -0600
Message-ID: <fa686aa40908201044y17acb4c1lacf09fafc2647fa4@mail.gmail.com>
References: <20090820094956.02DFC45004F@mail96-dub.bigfish.com>
	<20090820160356.F1A03340054@mail79-sin.bigfish.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Sadanand Mutyala <sadanan@xilinx.com>, netdev@vger.kernel.org,
	John Linn <john.linn@xilinx.com>, linuxppc-dev@ozlabs.org,
	John Linn <linnj@xilinx.com>,
	Michal Simek <michal.simek@petalogix.com>, jgarzik@pobox.com,
	davem@davemloft.net, John Williams <john.williams@petalogix.com>
To: Stephen Neuendorffer <stephen.neuendorffer@xilinx.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20090820160356.F1A03340054@mail79-sin.bigfish.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 20, 2009 at 10:02 AM, Stephen
Neuendorffer<stephen.neuendorffer@xilinx.com> wrote:
>
> John,
>
> I just got a chance to browse this... =A0Do you want to put in the
> stripped device names?
>
> .compatible =3D "xlnx,xps-ethernetlite-2", etc...

We've covered this territory before.  Compatible values need to be
exact for the IP cores.  No wildcards. No abbreviations or stripping.
Newer cores can claim compatibility with older when appropriate.

g.

-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
