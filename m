From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: snmp stats for Fast Open, SYN rtx, and
 data pkts
Date: Fri, 28 Feb 2014 16:07:53 -0800
Message-ID: <1393632473.26794.90.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393627642-19302-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Nandits Dukkipati <nanditad@google.com>,
	Larry Brakmo <brakmo@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:34500 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234AbaCAAHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 19:07:55 -0500
Received: by mail-pb0-f43.google.com with SMTP id um1so1414437pbc.30
        for <netdev@vger.kernel.org>; Fri, 28 Feb 2014 16:07:55 -0800 (PST)
In-Reply-To: <1393627642-19302-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-02-28 at 14:47 -0800, Yuchung Cheng wrote:
> Add the following snmp stats:
> 
> TCPFastOpenActiveFail: Fast Open attempts (SYN/data) failed beacuse
> the remote does not accept it or the attempts timed out.
> 
> TCPSynRetrans: number of SYN and SYN/ACK retransmits to break down
> retransmissions into SYN, fast-retransmits, timeout retransmits, etc.
> 
> TCPOrigDataSent: number of outgoing packets with original data (excluding
> retransmission but including data-in-SYN). This counter is different from
> TcpOutSegs because TcpOutSegs also tracks pure ACKs. TCPOrigDataSent is
> more useful to track the TCP retransmission rate.
> 
> Change TCPFastOpenActive to track only successful Fast Opens to be symmetric to
> TCPFastOpenPassive.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Nandits Dukkipati <nanditad@google.com>

s/Nandits/Nandita/

> Signed-off-by: Larry Brakmo <brakmo@google.com>
> ---
