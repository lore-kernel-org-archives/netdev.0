From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [8390] Do not use dev->name before register_netdev
Date: Sun, 14 Mar 2004 17:53:12 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040314065312.GA22999@gondor.apana.org.au>
References: <20040313025859.GA8186@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="FL5UXtIhxfXey3p5"
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040313025859.GA8186@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--FL5UXtIhxfXey3p5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Mar 13, 2004 at 01:58:59PM +1100, herbert wrote:
> 
> This patch replaces/removes all uses of dev->name in 8390 drivers.
> As it is, these drivers will do printks or allocate resources with
> the name eth%d.

I forgot to export register_ei_netdev for the modules.  Here is a
patch on top of the last one which does this.
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--FL5UXtIhxfXey3p5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

Index: kernel-2.5/drivers/net/8390.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/8390.c,v
retrieving revision 1.2
diff -u -r1.2 8390.c
--- kernel-2.5/drivers/net/8390.c	13 Mar 2004 02:27:30 -0000	1.2
+++ kernel-2.5/drivers/net/8390.c	14 Mar 2004 06:51:59 -0000
@@ -1148,6 +1148,7 @@
 EXPORT_SYMBOL(ei_tx_timeout);
 EXPORT_SYMBOL(NS8390_init);
 EXPORT_SYMBOL(__alloc_ei_netdev);
+EXPORT_SYMBOL(register_ei_netdev);
 
 #if defined(MODULE)
 

--FL5UXtIhxfXey3p5--
