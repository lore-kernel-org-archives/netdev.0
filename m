From: Jeff Garzik <jgarzik@pobox.com>
Subject: NAPI note (was Re: lockups with 2.4.20 (tg3? net/core/dev.c|deliver_to_old_ones))
Date: Fri, 14 Feb 2003 18:58:13 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E4D8295.2050400@pobox.com>
References: <3E4D66DF.3040800@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pete Zaitcev <zaitcev@redhat.com>, James Bourne <jbourne@mtroyal.ab.ca>,
   davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <3E4D66DF.3040800@colorfullife.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Manfred Spraul wrote:
> It seems to be a generic NAPI restriction:
> The caller of netif_receive_skb() must not own a spinlock that is 
> acquired from an interrupt handler.


Thanks much for noticing this, Manfred.  tg3 is definitely buggy in this 
regard.  I've CC'd netdev as an FYI...  We should probably patch 
NAPI_HOWTO for this note.

I note that David pointed this out as an area for improvement, so he was 
already thinking in this direction anyway :)

	Jeff
