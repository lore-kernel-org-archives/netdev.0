From: "David S. Miller" <davem@redhat.com>
Subject: Re: NAPI for eepro100
Date: Wed, 12 Jun 2002 16:33:44 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae8m5b$8tb$2@main.gmane.org>
References: <3D07D270.5060902@mandrakesoft.com>
	<20020612.160532.134201977.davem@redhat.com>
	<3D07D6A6.7090308@mandrakesoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fxzhang@ict.ac.cn, linux-mips@oss.sgi.com, saw@saw.sw.com.sg,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: jgarzik@mandrakesoft.com
In-Reply-To: <3D07D6A6.7090308@mandrakesoft.com>
List-Id: netdev.vger.kernel.org

   From: Jeff Garzik <jgarzik@mandrakesoft.com>
   Date: Wed, 12 Jun 2002 19:17:58 -0400

   Oh crap, you're right...   eepro100 in general does funky stuff with the 
   way packets are handled, mainly due to the need to issue commands to the 
   NIC engine instead of the normal per-descriptor owner bit way of doing 
   things.

The question is, do the descriptor bits have to live right before
the RX packet data buffer or can other schemes be used?
