From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 0/6] bnx2: Misc fixes
Date: Mon, 23 May 2005 16:53:59 -0700
Message-ID: <1116892439.4908.1.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

These patches fix the following problems spotted by Jeff Garzik. Thanks
Jeff.

> 8) excessive stack size in bnx2_alloc_bad_rbuf():

> 13) [additional review] why is CHECKSUM_UNNECESSARY used when
> cksum==0xffff or cksum==0 ?

> 15) the following loop is just silly.  use mdelay or (preferably)
> msleep.

> 19) [additional review] need flush_scheduled_work(), if using work
queues?

> 21) need to call bnx2_netif_stop() in bnx2_close()
