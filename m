From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] skb_headlen() cleanup
Date: Sun, 06 Apr 2003 23:58:58 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030406.235858.74068211.davem@redhat.com>
References: <Mutt.LNX.4.44.0304070230370.26415-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Mutt.LNX.4.44.0304070230370.26415-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: James Morris <jmorris@intercode.com.au>
   Date: Mon, 7 Apr 2003 02:34:34 +1000 (EST)

   A few bits of code in the drivers and networking are using:
   
     skb->len - skb->data_len
   
   which is what skb_headlen() calculates.
   
   The patch below (against recent 2.5 bk) converts these to use 
   skb_headlen().
   
Applied, thanks James.
