From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: e100 in net-drivers-2.5-exp
Date: Tue, 16 Dec 2003 17:36:20 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FDF88E4.1060002@pobox.com>
References: <20031216104326.70809423.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040106010807090306050509"
Cc: "Feldman, Scott" <scott.feldman@intel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031216104326.70809423.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040106010807090306050509
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Stephen Hemminger wrote:
> e100 in net-drivers-2.5-exp won't compile as a module.
> 
> Don't think the new module_param() works the way it is being used
> in the new e100 driver.
> 
>   CC [M]  drivers/net/e100.o
> drivers/net/e100.c:170: error: parse error before "int"
> drivers/net/e100.c:170: warning: type defaults to `int' in declaration of `module_param'
> drivers/net/e100.c:170: warning: function declaration isn't a prototype
> drivers/net/e100.c:170: warning: data definition has no type or storage class

Thanks, just checked in the attached patch to fix this.

--------------040106010807090306050509
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

===== drivers/net/e100.c 1.2 vs edited =====
--- 1.2/drivers/net/e100.c	Tue Dec  9 15:38:42 2003
+++ edited/drivers/net/e100.c	Tue Dec 16 17:35:12 2003
@@ -136,6 +136,7 @@
 
 #include <linux/config.h>
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/slab.h>

--------------040106010807090306050509--
