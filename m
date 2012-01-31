From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH iproute2] tc-sfq: update man page
Date: Tue, 31 Jan 2012 13:38:28 +0100
Message-ID: <4F27E0C4.1050609@computer.org>
References: <1327411778.7231.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay012.isp.belgacom.be ([195.238.6.179]:47923 "EHLO
	mailrelay012.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752256Ab2AaMj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 07:39:26 -0500
In-Reply-To: <1327411778.7231.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/24/2012 02:29 PM, Eric Dumazet wrote:
> Add documentation about RED mode, and new parameters (flows, depth)
> added in linux 3.3
>
> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
> ---
>   man/man8/tc-sfq.8 |  127 +++++++++++++++++++++++++++++++++++++-------
>   1 file changed, 108 insertions(+), 19 deletions(-)
>
> diff --git a/man/man8/tc-sfq.8 b/man/man8/tc-sfq.8
> index e177f56..5a651ff 100644
> --- a/man/man8/tc-sfq.8
> +++ b/man/man8/tc-sfq.8
...
+Source and Destination port
>   .P
>   If these are available. SFQ knows about ipv4 and ipv6 and also UDP, TCP and ESP.
>   Packets with other protocols are hashed based on the 32bits representation of their
> -destination and the socket they belong to. A flow corresponds mostly to a TCP/IP
> -connection.
> +destination and source. A flow corresponds mostly to a TCP/IP connection.

Don't understand this. Did you want to replace "connection" by 
"destination and source"? Do you mean that a "connection" is 
characterised by source and destination?
