From: Mazhar Memon <mazhar@nmt.edu>
Subject: skb->len
Date: Mon, 23 Sep 2002 18:25:54 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020923182554.1f84d429.mazhar@nmt.edu>
References: <Pine.LNX.4.33L2.0204091358030.22258-100000@dragon.pdx.osdl.net>
	<20020410.202811.103858854.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20020410.202811.103858854.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Is there a reason why skb->len for skb->pkt_type=PACKET_OUTGOING is 14 bytes larger than for skb->pkt_type=PACKET_HOST?  I doubt its a coincidence that the size of the ethernet header is 14 bytes.  Also, I notice that skb->data starts at a different location (relative to the ethernet header) if its outgoing compared to incoming traffic.  Can anyone tell me why?

Regards,
Mazhar
