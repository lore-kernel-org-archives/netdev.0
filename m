From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][2.4] more atm changes backported to 2.4
Date: Fri, 11 Jul 2003 23:52:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030711235247.43f05654.davem@redhat.com>
References: <200307102033.h6AKXtsG006493@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net
In-Reply-To: <200307102033.h6AKXtsG006493@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 On Thu, 10 Jul 2003 16:31:32 -0400
chas williams <chas@cmf.nrl.navy.mil> wrote:

> #	           ChangeSet	1.1014  -> 1.1015 
> #	       net/atm/lec.c	1.15    -> 1.16   
> #
> # The following is the BitKeeper ChangeSet Log
> # --------------------------------------------
> # 03/06/27	chas@relax.cmf.nrl.navy.mil	1.1015
> # elminate cli, make function names sane
> # --------------------------------------------

Forgot some net/atm/lec.h changes for this one Chas? :-(
See the patch below I had to add to my tree to get things
building again.

Chas, please, type "make" in a tree that has only the patches you are
sending me applied.  I know you said to me this is "hard" for you to
do, but after this I really need you to start doing this.

Thanks.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1084  -> 1.1085 
#	       net/atm/lec.h	1.4     -> 1.5    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/07/11	davem@nuts.ninka.net	1.1085
# [ATM]: Fix build, missing lec_priv member.
# --------------------------------------------
#
diff -Nru a/net/atm/lec.h b/net/atm/lec.h
--- a/net/atm/lec.h	Fri Jul 11 23:58:23 2003
+++ b/net/atm/lec.h	Fri Jul 11 23:58:23 2003
@@ -101,7 +101,7 @@
            establishes multiple Multicast Forward VCCs to us. This list
            collects all those VCCs. LANEv1 client has only one item in this
            list. These entries are not aged out. */
-        atomic_t lec_arp_lock_var;
+        atomic_t lec_arp_users;
         struct atm_vcc *mcast_vcc; /* Default Multicast Send VCC */
         struct atm_vcc *lecd;
         struct timer_list lec_arp_timer;
