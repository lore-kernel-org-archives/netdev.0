From: "Michael Chan" <mchan@broadcom.com>
Subject: RE: [PATCH] fix BUG in tg3_tx
Date: Mon, 24 May 2004 10:33:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <B1508D50A0692F42B217C22C02D849727FEDB0@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@redhat.com>, "Greg Banks" <gnb@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> David,
> 
> The producer index of completed tx packets in the status 
> block will always be at whole packet boundaries (1 + the 
> index of the completed packet's last fragment). Even if it is 
> a TSO packet, it will be at the boundaries of entire TSO packets.
> 
> Michael
> 

Minor correction - I should have said the send BD consumer index instead
of the producer index.
