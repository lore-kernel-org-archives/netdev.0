From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH 2.6.19-rc3 2/2] ehea: 64K page support fix
Date: Thu, 26 Oct 2006 02:21:27 +1000
Message-ID: <20061025162126.GB25324@krispykreme>
References: <200610251312.01235.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Klein <tklein@de.ibm.com>, Jeff Garzik <jeff@garzik.org>,
	Jan-Bernd Themann <themann@de.ibm.com>, netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>, Christoph Raisch <raisch@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Content-Disposition: inline
In-Reply-To: <200610251312.01235.ossthema@de.ibm.com>
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


Hi,

> +#ifdef CONFIG_PPC_64K_PAGES
> +	/* To support 64k pages we must round to 64k page boundary */
> +	epas->kernel.addr =
> +		ioremap((paddr_kernel & 0xFFFFFFFFFFFF0000), PAGE_SIZE) +
> +		(paddr_kernel & 0xFFFF);
> +#else
>  	epas->kernel.addr = ioremap(paddr_kernel, PAGE_SIZE);
> +#endif

Cant you just use PAGE_MASK, ~PAGE_MASK and remove the ifdefs
completely?

Anton
