From: Stephen Hemminger <shemminger@osdl.org>
Subject: e100 in net-drivers-2.5-exp
Date: Tue, 16 Dec 2003 10:43:26 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031216104326.70809423.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>,
        Jeff Garzik
 <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

e100 in net-drivers-2.5-exp won't compile as a module.

Don't think the new module_param() works the way it is being used
in the new e100 driver.

  CC [M]  drivers/net/e100.o
drivers/net/e100.c:170: error: parse error before "int"
drivers/net/e100.c:170: warning: type defaults to `int' in declaration of `module_param'
drivers/net/e100.c:170: warning: function declaration isn't a prototype
drivers/net/e100.c:170: warning: data definition has no type or storage class


-- 
Stephen Hemminger 		mailto:shemminger@osdl.org
Open Source Development Lab	http://developer.osdl.org/shemminger
