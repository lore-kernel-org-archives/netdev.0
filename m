From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] UDPCP Communication Protocol
Date: Fri, 31 Dec 2010 09:46:58 -0800
Message-ID: <20101231094658.1881c113@s6510>
References: <1293787785-3834-1-git-send-email-stefani@seibold.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: stefani@seibold.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293787785-3834-1-git-send-email-stefani@seibold.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 31 Dec 2010 10:29:45 +0100
stefani@seibold.net wrote:

> +/*
> + * UDPCP destination descriptor
> + *
> + * For each communication address an individual destination descriptor will
> + * be create.
> + *
> + * The fields has the following meanings:
> + *
> + * list:		link list: part of udpcp_sock.destlist
> + * xmit:		messages fragments to be transmit
> + * tx_time:		timestamp of the last transmitted message fragment
> + * rx_time:		timestamp ot the last received message fragment
> + * txTimeout:		statistic use only: number of transmit timeout
> + * rxTimeout:		statistic use only: number of receive timeout
> + * txRetries:		statistic use only: number of transmit retries
> + * rxDiscardedFrags:	statistic use only: number of discarded messages
> + * xmit_wait:		message fragment which is waiting for an ACK
> + * xmit_last:		last fragment transmitted
> + * recv_msg:		first fragment of the received message
> + * recv_last:		last fragment of the received message
> + * lastmsg:		last messages fragment header received
> + * ipc:			linux internal ipc cookie
> + * fl:			flow/routing information
> + * rt:			routing entry currently used for this destination
> + * addr:		ipv4 destination address
> + * port:		destination port number
> + * msgid:		current message id for outgoing data messages
> + * use_flag:		statistic use only: flag for dest using TX and/or RX
> + * insync:		flag for protocol synchronization
> + * ackmode;		ack mode for the current assembled message
> + * chkmode;		checksum mode for the current assembled message
> + * try:			current number of retries xmit_wait message
> + * acks:		number of outstandig ack's
> + */

Why not use docbook format comments for this?
