From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Convert pppoe to new style protocol
Date: Tue, 17 Jun 2003 15:07:51 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617.150751.52901849.davem@redhat.com>
References: <20030617220420.GA1169@averell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mostrows@speakeasy.net, paulus@au.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@muc.de
In-Reply-To: <20030617220420.GA1169@averell>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andi Kleen <ak@muc.de>
   Date: Wed, 18 Jun 2003 00:04:20 +0200

   Convert pppoe to a new style protocol, otherwise it is unusable 
   on SMP compiled kernels because of the printk in deliver*old_ones.
   It works fine here, but only tested on a UP box.

Please don't add new skb_linearize() users, I'm trying
to make that only local to net/core/dev.c

Otherwise I'm fine with your patch.
