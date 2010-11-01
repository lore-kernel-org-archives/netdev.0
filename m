From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] OF device tree: Move of_get_mac_address() to a common
	source file.
Date: Mon, 1 Nov 2010 01:17:34 -0400
Message-ID: <20101101051734.GB17587@angua.secretlab.ca>
References: <1288130833-16421-1-git-send-email-ddaney@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, Corey Minyard <cminyard@mvista.com>,
	Anton Vorontsov <avorontsov@mvista.com>, Paul Mackerras <paulus@samba.org>,
	Sadanand Mutyala <Sadanand.Mutyala@xilinx.com>,
	Sergey Matyukevich <geomatsi@gmail.com>,
	Sean MacLennan <smaclennan@pikatech.com>,
	Wolfgang Denk <wd@denx.de>, microblaze-uclinux@itee.uq.edu.au,
	devicetree-discuss@lists.ozlabs.org, Andres Salomon <dilinger@queued.net>,
	Michal Simek <monstr@monstr.eu>, Anatolij Gustschin <agust@denx.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ralf@linux-mips.org,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>, linuxppc-dev@lists.ozlabs.org,
	"David S. Miller" <davem@davemloft.net>
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <1288130833-16421-1-git-send-email-ddaney@caviumnetworks.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 26, 2010 at 03:07:13PM -0700, David Daney wrote:
> There are two identical implementations of of_get_mac_address(), one
> each in arch/powerpc/kernel/prom_parse.c and
> arch/microblaze/kernel/prom_parse.c.  Move this function to a new
> common file of_net.{c,h} and adjust all the callers to include the new
> header.

Applied, thanks; but made some changes to protect this code because it
does not work on little endian (it can be fixed in a separate patch)

Also...

> 
> Signed-off-by: David Daney <ddaney@caviumnetworks.com>
> Cc: Michal Simek <monstr@monstr.eu>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Wolfram Sang <w.sang@pengutronix.de>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Corey Minyard <cminyard@mvista.com>
> Cc: Pantelis Antoniou <pantelis.antoniou@gmail.com>
> Cc: Vitaly Bordug <vbordug@ru.mvista.com>
> Cc: Anatolij Gustschin <agust@denx.de>
> Cc: John Rigby <jcrigby@gmail.com>
> Cc: Wolfgang Denk <wd@denx.de>
> Cc: Anton Vorontsov <avorontsov@mvista.com>
> Cc: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
> Cc: Kumar Gala <galak@kernel.crashing.org>
> Cc: Li Yang <leoli@freescale.com>
> Cc: Sergey Matyukevich <geomatsi@gmail.com>
> Cc: Jiri Pirko <jpirko@redhat.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Sean MacLennan <smaclennan@pikatech.com>
> Cc: Sadanand Mutyala <Sadanand.Mutyala@xilinx.com>
> Cc: Andres Salomon <dilinger@queued.net>
> Cc: microblaze-uclinux@itee.uq.edu.au
> Cc: linux-kernel@vger.kernel.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: netdev@vger.kernel.org
> Cc: devicetree-discuss@lists.ozlabs.org

You don't need to believe everything that get_maintainers is telling
you.  When you get a large list like this, don't Cc everyone, but
apply some educated guesses.  You can guess that the PowerPC and
Microblaze maintainers care because it touches their trees, and you
can guess that I care because I'm the dt maintainer. David Miller
isn't a bad guess because of networking.  But 22 people is excessive.

g.
