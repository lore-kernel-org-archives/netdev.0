From: Casey Carter <Casey@Carter.net>
Subject: Re: injecting packets
Date: Tue, 16 Apr 2002 17:27:50 -0500
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3CBCA566.4000504@Carter.net>
References: <Pine.LNX.4.30.0204161203210.15280-100000@brahmi.ee.iitb.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Vasu <vasu@ee.iitb.ac.in>
List-Id: netdev.vger.kernel.org

It sounds like you want the Universal Tunnel/Tap driver, that lives in 
drivers/net/tun.c

Vasu wrote:

>Hi.
>
>I am trying to write a module that takes Ethernet packets from the user
>domain, and injects it into the proper place ( which I think is the
>sk_buffers ), so that to the IP, TCP layer, the packets look as if coming
>from the Ethernet device. Can someone please suggest me which files to
>look into, and which structs to handle, for getting this done. Also, I
>want to do the reverse task, i.e. take some particular packets ( say which
>come from a specific port ) from sk_buffers and send it to user space.
>
>Please assume that this silly looking Rx/Tx has some importance :)
>
>Regards.
>
>Vasu.
>III yr EE student.
>
>
>-
>To unsubscribe from this list: send the line "unsubscribe linux-net" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



