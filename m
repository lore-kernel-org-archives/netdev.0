From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Fwd: in-driver QoS
Date: Mon, 07 Jun 2004 15:38:23 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40C4C42F.2040006@pobox.com>
References: <200406072217.31924.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Ketrenos <jketreno@linux.jf.intel.com>, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200406072217.31924.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Vladimir Kondratiev wrote:
> skb->priority help determining Tx queue, but fundamental problem is with
> single Tx queue from network stack. Any smart queuing/scheduling etc. made by
> driver, will render useless while network stack provides single Tx queue.


The packet schedulers already have multiple queues, why isn't the packet 
scheduling framework sufficient?

Who cares if there is a single TX "delivery point" to the driver, as 
long as the driver knows how to differentiate queues.

	Jeff
