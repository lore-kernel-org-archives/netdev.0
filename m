From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH 2.4.26] add prism54 to 2.4 tree
Date: Tue, 20 Jul 2004 10:24:53 -0300
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040720132453.GA2348@dmt.cyclades>
References: <20040715005140.GH14482@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <prism54-devel-bounces@prism54.org>
To: Netdev <netdev@oss.sgi.com>, prism54-devel@prism54.org,
	jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040715005140.GH14482@ruslug.rutgers.edu>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 14, 2004 at 08:51:40PM -0400, Luis R. Rodriguez wrote:
> 
> Marcelo,
> 
> Attached patch adds prism54 to 2.4 tree. This patch applies cleanly to
> 2.4.27-rc3 as well.

Hi Luis, 

This looks fine for inclusion on 2.4.28-pre, after Jeff/others take a look 
at it. 

> GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

> --- linux-2.4.26/Documentation/Configure.help	2004-04-14 13:05:24.000000000 +0000
> +++ linux-2.4.26-prism54/Documentation/Configure.help	2004-07-15 00:30:04.000000000 +0000
> @@ -9968,6 +9968,49 @@
>    compile it as a module, say M here and read
>    <file:Documentation/modules.txt>.
>  
> +Intersil 802.11(a/b/g) Prism GT/Duette/Indigo support
> +CONFIG_PRISM54
> +  Enable PCI and Cardbus support for the following chipset based cards:
> +
> +  ISL3880 - Prism GT		802.11 b/g
> +  ISL3877 - Prism Indigo	802.11 a
> +  ISL3890 - Prism Duette	802.11 a/b/g
> +  
> +  For a complete list of supported cards visit <http://prism54.org>.
> +  Here is the latest confirmed list of supported cards:
> +
> +  3com OfficeConnect 11g Cardbus Card aka 3CRWE154G72
> +  Allnet ALL0271 PCI Card
> +  Compex WL54G Cardbus Card
> +  Corega CG-WLCB54GT Cardbus Card
> +  D-Link Air Plus Xtreme G A1 Cardbus Card aka DWL-g650
> +  I-O Data WN-G54/CB Cardbus Card
> +  Kobishi XG-300 aka Z-Com Cardbus Card
> +  Netgear WG511 Cardbus Card
> +  Ovislink WL-5400PCI PCI Card
> +  Peabird WLG-PCI PCI Card
> +  Sitecom WL-100i Cardbus Card
> +  Sitecom WL-110i PCI Card
> +  SMC2802W - EZ Connect g 2.4GHz 54 Mbps Wireless PCI Card
> +  SMC2835W - EZ Connect g 2.4GHz 54 Mbps Wireless Cardbus Card
> +  Z-Com XG-900 PCI Card
> +  Zyxel G-100 Cardbus Card
> +
> +  If you enable this, you require a firmware file as well.
> +  You will need to copy this to /usr/lib/hotplug/firmware/isl3890.
> +  You can get this non-GPL'd firmware file from the Prism54 project page:
> +  <http://prism54.org>.
> +  You will also need the /etc/hotplug/firmware.agent script from
> +  a current hotplug package.
> +
> +
> +  Note: You need a motherboard with DMA support to use any of these cards 
> +  
> +  If you want to compile the driver as a module ( = code which can be
> +  inserted in and removed from the running kernel whenever you want),
> +  say M here and read <file:Documentation/modules.txt>.  The module
> +  will be called prism54.o.
> +
>  Aironet 4500/4800 PROC interface
>  CONFIG_AIRONET4500_PROC
>    If you say Y here (and to the "/proc file system" below), you will
