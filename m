From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [janitor] depca: release resources on errors
Date: Sun, 25 Jan 2004 23:25:14 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <401496AA.4000404@pobox.com>
References: <20040124223109.1c134ca1.rddunlap@osdl.org>	<4013F096.4090705@pobox.com> <20040125193017.450d6ff8.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, ogasawara@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <20040125193017.450d6ff8.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Randy.Dunlap wrote:
> On Sun, 25 Jan 2004 11:36:38 -0500 Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> | Most of these patches you're sending are already in netdev-2.6, AFAICS...
> 
> 
> net: remove unnecessary type casting -- not found in netdev

I applied this one


> tc35815: handle ioremap() failure -- still missed (*Leann)

         dev->base_addr = (unsigned long)ioremap(base_addr, 
sizeof(struct tc35815_regs));
         if (!dev->base_addr) {
                 ret = -ENOMEM;
                 goto err_out;
         }


> dgrs: add iounmap()s to failure paths -- still missed (*Leann)

this wants fixing as well
