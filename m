From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: TCP output handling bug ?
Date: Thu, 21 Aug 2014 19:02:08 +0100
Message-ID: <20140821190208.208e0de1@www.etchedpixels.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 251.110.2.81.in-addr.arpa ([81.2.110.251]:54285 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065AbaHUSCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 14:02:15 -0400
Received: from www.etchedpixels.co.uk (localhost [127.0.0.1])
	by lxorguk.ukuu.org.uk (8.14.7/8.14.1) with ESMTP id s7LI7FHI016115
	for <netdev@vger.kernel.org>; Thu, 21 Aug 2014 19:07:20 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


tcp_send_syn_data:

        TCP_SKB_CB(data)->tcp_flags &= ~TCPHDR_SYN;
        TCP_SKB_CB(data)->tcp_flags = (TCPHDR_ACK|TCPHDR_PSH);

the reporter has a point 8)


https://bugzilla.kernel.org/show_bug.cgi?id=82101
