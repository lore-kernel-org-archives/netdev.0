From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH] af_packet: don't pass empty blocks for PACKET_V3
Date: Tue, 24 Feb 2015 16:09:58 -0500 (EST)
Message-ID: <20150224.160958.1491397927638460390.davem@davemloft.net>
References: <1423115891-3578-1-git-send-email-al.drozdov@gmail.com>
	<1424755108-10493-1-git-send-email-al.drozdov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, edumazet@google.com, viro@zeniv.linux.org.uk,
	willemb@google.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dan@dcollins.co.nz, guy@alum.mit.edu
To: al.drozdov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424755108-10493-1-git-send-email-al.drozdov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Drozdov <al.drozdov@gmail.com>
Date: Tue, 24 Feb 2015 08:18:28 +0300

> Before da413eec729d ("packet: Fixed TPACKET V3 to signal poll when block is
> closed rather than every packet") poll listening for an af_packet socket was
> not signaled if there was no packets to process. After the patch poll is
> signaled evety time when block retire timer expires. That happens because
> af_packet closes the current block on timeout even if the block is empty.
> 
> Passing empty blocks to the user not only wastes CPU but also wastes ring
> buffer space increasing probability of packets dropping on small timeouts.
> 
> Signed-off-by: Alexander Drozdov <al.drozdov@gmail.com>

Applied, thanks.
