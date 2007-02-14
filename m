From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch 21/21] Xen-paravirt: Add the Xen virtual network device
	driver.
Date: Wed, 14 Feb 2007 13:40:01 -0700
Message-ID: <m1odnwpj6m.fsf@ebiederm.dsl.xmission.com>
References: <20070213221729.772002682@goop.org>
	<20070213221831.150207238@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Andrew Morton <akpm@osdl.org>, Andi Kleen <ak@muc.de>,
   xen-devel@lists.xensource.com, Chris Wright <chrisw@sous-sol.org>,
   Ian Pratt <ian.pratt@xensource.com>, virtualization@lists.osdl.org,
   netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <virtualization-bounces@lists.osdl.org>
In-Reply-To: <20070213221831.150207238@goop.org> (Jeremy Fitzhardinge's
	message of "Tue, 13 Feb 2007 14:17:50 -0800")
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.osdl.org>
List-Help: <mailto:virtualization-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.osdl.org?subject=subscribe>
Sender: virtualization-bounces@lists.osdl.org
Errors-To: virtualization-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

Jeremy Fitzhardinge <jeremy@goop.org> writes:

> +++ b/drivers/xen/Kconfig.net
> @@ -0,0 +1,14 @@
> +menu "Xen network device drivers"
> +        depends on NETDEVICES && XEN
> +
> +config XEN_NETDEV_FRONTEND
> +	tristate "Network-device frontend driver"
> +	depends on XEN
> +	default y
> +	help
> +	  The network-device frontend driver allows the kernel to access
> +	  network interfaces within another guest OS. Unless you are building a
> +	  dedicated device-driver domain, or your master control domain
> +	  (domain 0), then you almost certainly want to say Y here.

Am I reading this correctly I can directly use the network interface
of another guest OS (no protection)?

I think this description is misleading, and probably say something
about virtual hardware.

Eric
