From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: dummy as IMQ replacement
Date: 09 Mar 2005 20:06:07 -0500
Message-ID: <1110416767.1111.76.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <0fcf01c5077f$579e4b80$6e69690a@RIMAS>
	 <1107174142.8021.121.camel@jzny.localdomain>
	 <00c301c524b4$938cd240$6e69690a@RIMAS>
	 <1110379135.1091.143.camel@jzny.localdomain>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-XPicLd45+Kfs/6uczpzT"
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Andre Tomt <andre@tomt.net>, syrius.ml@no-log.org,
        Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
To: Remus <rmocius@auste.elnet.lt>
In-Reply-To: <1110379135.1091.143.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-XPicLd45+Kfs/6uczpzT
Content-Transfer-Encoding: 7bit
Content-Type: text/plain

Hi Remus,

Please try this patch on top of latest iproute2. Credit to Patrick for
spoting it. I dont know when or who made this change - in any case it
doesnt matter if it works for you.

cheers,

On Wed, 2005-03-09 at 09:38, jamal wrote:

> I have to go to work - so wont have time to look at this for sometime.
> Maybe some of the netfilter folks like Patrick can solve it for you
> before i get back.
> 
> cheers,
> jamal
> 

--=-XPicLd45+Kfs/6uczpzT
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=ipt-p
Content-Type: text/plain; name=ipt-p; charset=ISO-8859-1

--- iproute2-a/tc/m_ipt.c	2005/03/10 00:59:38	1.1
+++ iproute2-b/tc/m_ipt.c	2005/03/10 01:00:05
@@ -72,7 +72,6 @@
 static unsigned int global_option_offset = 0;
 #define OPTION_OFFSET 256
 
-#if 0
 /* no clue why register match is within targets
  figure out later. Talk to Harald -- JHS
 */
@@ -91,7 +90,6 @@
 	t_list = me;
 
 }
-#endif
 
 void
 exit_tryhelp(int status)

--=-XPicLd45+Kfs/6uczpzT--
