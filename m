From: Werner Almesberger <wa@almesberger.net>
Subject: Re: [PATCH] Convert pppoe to new style protocol
Date: Wed, 18 Jun 2003 09:21:26 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030618092126.A28100@almesberger.net>
References: <20030617220420.GA1169@averell> <20030617.150751.52901849.davem@redhat.com> <20030618080118.GC23037@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@muc.de, netdev@oss.sgi.com, mostrows@speakeasy.net, paulus@au.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030618080118.GC23037@wotan.suse.de>; from ak@suse.de on Wed, Jun 18, 2003 at 10:01:18AM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jun 17, 2003 at 03:07:51PM -0700, David S. Miller wrote:
> Please don't add new skb_linearize() users, I'm trying
> to make that only local to net/core/dev.c

I know you find documentation unmanly, but maybe ...

- Werner

--- skbuff.h.orig	Wed Jun 18 09:13:57 2003
+++ skbuff.h	Wed Jun 18 09:15:05 2003
@@ -1126,6 +1126,9 @@
  *
  *	If there is no free memory -ENOMEM is returned, otherwise zero
  *	is returned and the old skb data released.
+ *
+ *	DO NOT USE THIS IN NEW CODE ! skb_linearize will be for internal
+ *	use by net/core/dev.c only.
  */
 int skb_linearize(struct sk_buff *skb, int gfp);
 
-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
