From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Convert pppoe to new style protocol
Date: Wed, 18 Jun 2003 16:36:00 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030618.163600.71097155.davem@redhat.com>
References: <20030617.150751.52901849.davem@redhat.com>
	<20030618080118.GC23037@wotan.suse.de>
	<20030618092126.A28100@almesberger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@muc.de, netdev@oss.sgi.com, mostrows@speakeasy.net, paulus@au.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: wa@almesberger.net
In-Reply-To: <20030618092126.A28100@almesberger.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Werner Almesberger <wa@almesberger.net>
   Date: Wed, 18 Jun 2003 09:21:26 -0300

   + *
   + *	DO NOT USE THIS IN NEW CODE ! skb_linearize will be for internal
   + *	use by net/core/dev.c only.
     */
    int skb_linearize(struct sk_buff *skb, int gfp);

I have a better idea, I just added the __deprecated tag
to this function declaration :-)
