From: "David S. Miller" <davem@redhat.com>
Subject: Re: acenic lockup
Date: Wed, 07 May 2003 12:34:21 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030507.123421.133894691.davem@redhat.com>
References: <20030506.234316.68138442.davem@redhat.com>
	<200305071706.VAA00295@mops.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, jes@trained-monkey.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200305071706.VAA00295@mops.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
   Date: Wed, 7 May 2003 21:06:32 +0400 (MSD)
   
   I remember we discussed this with Dave
   and he was very angry about this flaw shared by most of drivers
   and, seems, did not eat this fix.
   
Yes, this netif_wake_queue() in acenic's watchdog routine
is bogus.  It is guarenteed lockup.

Ok, I applied this.

However, what does kick device back into working state?

Do we make shamans dance when this message hits the logs
and pray for the best? :-)
