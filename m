From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Sat, 09 May 2009 13:31:28 -0700 (PDT)
Message-ID: <20090509.133128.150633653.davem@davemloft.net>
References: <1241559489.5921.13.camel@bender>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	kaber@trash.net, hadi@cyberus.ca, cl@linux.com, zbr@ioremap.net
To: johann.baudy@gnu-log.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37253
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752218AbZEIUbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2009 16:31:32 -0400
In-Reply-To: <1241559489.5921.13.camel@bender>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johann Baudy <johann.baudy@gnu-log.net>
Date: Tue, 05 May 2009 23:38:09 +0200

> New packet socket feature that makes packet socket more efficient for transmission.
> - It reduces number of system call through a PACKET_TX_RING mechanism, based on PACKET_RX_RING (Circular buffer allocated in kernel space which is mmapped from user space).
> - It minimizes CPU copy using fragmented SKB (almost zero copy).
> 
> Signed-off-by: Johann Baudy <johann.baudy@gnu-log.net>

I was about to apply this, but you need to fix the following
errors first.

+ git apply --check --whitespace=error-all TX_RING-and-packet-mmap.patch
TX_RING-and-packet-mmap.patch:303: trailing whitespace.
	/* Intermediate layers must ensure that destructor_arg 
TX_RING-and-packet-mmap.patch:416: trailing whitespace.
	
TX_RING-and-packet-mmap.patch:473: trailing whitespace.
static inline void *packet_current_frame(struct packet_sock *po, 
TX_RING-and-packet-mmap.patch:480: trailing whitespace.
static inline void *packet_previous_frame(struct packet_sock *po, 
TX_RING-and-packet-mmap.patch:542: trailing whitespace.
	
TX_RING-and-packet-mmap.patch:544: trailing whitespace.
	
TX_RING-and-packet-mmap.patch:552: trailing whitespace.
	
TX_RING-and-packet-mmap.patch:685: trailing whitespace.
		if (msg->msg_namelen < (saddr->sll_halen 
TX_RING-and-packet-mmap.patch:737: trailing whitespace.
				__packet_set_status(po, ph, 
TX_RING-and-packet-mmap.patch:955: trailing whitespace.
static int packet_set_ring(struct sock *sk, struct tpacket_req *req, 
TX_RING-and-packet-mmap.patch:1080: trailing whitespace.
		po->prot_hook.func = (po->rx_ring.pg_vec) ? 
TX_RING-and-packet-mmap.patch:1086: trailing whitespace.
			printk(KERN_DEBUG "packet_mmap: vma is busy: %d\n", 
TX_RING-and-packet-mmap.patch:1096: trailing whitespace.
static int packet_mmap(struct file *file, struct socket *sock, 
TX_RING-and-packet-mmap.patch:1119: trailing whitespace.
			expected_size += rb->pg_vec_len 
TX_RING-and-packet-mmap.patch:1120: trailing whitespace.
						* rb->pg_vec_pages 
TX_RING-and-packet-mmap.patch:1151: trailing whitespace.
			for (pg_num = 0; pg_num < rb->pg_vec_pages; 
TX_RING-and-packet-mmap.patch:1160: trailing whitespace.
	}	
TX_RING-and-packet-mmap.patch:1161: trailing whitespace.
	
fatal: 18 lines add whitespace errors.
