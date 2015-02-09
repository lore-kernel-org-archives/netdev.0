From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net] tcp: don't include Fast Open option in SYN-ACK on
 pure SYN-data
Date: Mon, 09 Feb 2015 14:27:32 -0800 (PST)
Message-ID: <20150209.142732.243638519161010259.davem@redhat.com>
References: <1423514123-6825-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, ncardwell@google.com, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44145 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761222AbbBIW1f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2015 17:27:35 -0500
In-Reply-To: <1423514123-6825-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Mon,  9 Feb 2015 12:35:23 -0800

> If a server has enabled Fast Open and it receives a pure SYN-data
> packet (without a Fast Open option), it won't accept the data but it
> incorrectly returns a SYN-ACK with a Fast Open cookie and also
> increments the SNMP stat LINUX_MIB_TCPFASTOPENPASSIVEFAIL.
> 
> This patch makes the server include a Fast Open cookie in SYN-ACK
> only if the SYN has some Fast Open option (i.e., when client
> requests or presents a cookie).
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Acked-by: Neal Cardwell <ncardwell@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
