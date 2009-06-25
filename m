From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] ucc_geth: Fix half-duplex operation for
	non-MII/RMII interfaces
Date: Thu, 25 Jun 2009 01:07:20 -0700 (PDT)
Message-ID: <20090625.010720.07013435.davem@davemloft.net>
References: <20090625010232.GA28590@oksana.dev.rtsoft.ru>
	<20090625070813.GA25653@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, leoli@freescale.com, afleming@freescale.com,
	netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20090625070813.GA25653@oksana.dev.rtsoft.ru>
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

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Thu, 25 Jun 2009 11:08:13 +0400

> On Thu, Jun 25, 2009 at 05:02:32AM +0400, Anton Vorontsov wrote:
>> Currently the half-duplex operation seems to not work reliably for
>> RGMII PHY interfaces. It takes about 10 minutes to boot NFS rootfs
>> using 10/half link, following symptoms were observed:
> 
> David, please ignore these patches, they just appear to
> workaround the issue, but they don't fix the root cause (which
> is unknown yet), and may cause other side to see the duplex
> errors. Heh...

Ok, thanks for the heads-up.
