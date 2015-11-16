From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] raw: increment correct SNMP counters for ICMP
 messages
Date: Mon, 16 Nov 2015 15:09:00 -0500 (EST)
Message-ID: <20151116.150900.193988253386004564.davem@davemloft.net>
References: <20151114151358.GA11387@benjojo.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ben+patches@benjojo.co.uk
To: Ben@Benjojo.co.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151114151358.GA11387@benjojo.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Cartwright-Cox <Ben@Benjojo.co.uk>
Date: Sat, 14 Nov 2015 15:13:58 +0000

> Sending ICMP packets with raw sockets ends up in the SNMP counters
> logging the type as the first byte of the IPv4 header rather than
> the ICMP header. This is fixed by adding the IP Header Length to
> the casting into a icmphdr struct.
> 
> Signed-off-by: Ben Cartwright-Cox <ben@benjojo.co.uk>
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
