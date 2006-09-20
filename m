From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH] Remove powerpc specific parts of 3c509 driver
Date: Wed, 20 Sep 2006 03:41:02 +0200
Message-ID: <96ED0FD1-ADE8-408B-82B1-CAB4D6964942@kernel.crashing.org>
References: <20060919145433.8fc7d478.sfr@canb.auug.org.au>
	<20060919184243.GL29167@austin.ibm.com>
	<45103C62.4080003@genesi-usa.com>
	<1158708269.6002.186.camel@localhost.localdomain>
	<488875E7-CCBC-47E1-A273-A2D037A997B2@kernel.crashing.org>
	<1158711935.6002.226.camel@localhost.localdomain>
	<9F6F4A8E-C780-4358-97AA-570B33C0598F@kernel.crashing.org>
	<20060920011750.GS29167@austin.ibm.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, Stephen Rothwell <sfr@canb.auug.org.au>,
	ppc-dev <linuxppc-dev@ozlabs.org>, netdev@vger.kernel.org,
	jgarzik@pobox.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20060920011750.GS29167@austin.ibm.com>
To: linas@austin.ibm.com (Linas Vepstas)
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

> Well, I'm having trouble thinking of other busses that have as strong
> a sense of the "address-data" style I/O as PCI. Busses like scsi and
> ide are primarily "command-data" or "data-data" in style.  Only the
> address-data style busses need readl/writel-style routines.

SBUS, JBUS, VMEbus, NuBus, RapidIO, eBus, various SoC busses, to name
a few.  There are many, and most are big-endian.


Segher
