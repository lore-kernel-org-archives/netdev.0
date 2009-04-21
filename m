From: Christoph Lameter <cl@linux.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29 (MSI off)
Date: Tue, 21 Apr 2009 15:36:32 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904211526580.5597@qirst.com>
References: <49E78A79.6050604@cosmosbay.com> <49E78C1E.9060405@cosmosbay.com> <alpine.DEB.1.10.0904161555040.23632@qirst.com> <20090416.160002.09845606.davem@davemloft.net> <alpine.DEB.1.10.0904171238550.20049@qirst.com> <49EA2D7F.3080405@cosmosbay.com>
 <alpine.DEB.1.10.0904201305360.1585@qirst.com> <49ECB775.6030202@cosmosbay.com> <alpine.DEB.1.10.0904201410430.3361@qirst.com> <49ECC30A.9040501@cosmosbay.com> <alpine.DEB.1.10.0904201510410.17816@qirst.com> <49ECD5E4.60100@cosmosbay.com>
 <alpine.DEB.1.10.0904201712140.27942@qirst.com> <49ECEE9E.7050307@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:37976 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753229AbZDUToj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 15:44:39 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E6AAC82C6F4
	for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 15:55:00 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 8PnxHYoAMq0H for <netdev@vger.kernel.org>;
	Tue, 21 Apr 2009 15:55:00 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 84D5882C6F5
	for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 15:54:58 -0400 (EDT)
In-Reply-To: <49ECEE9E.7050307@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Switching off MSI increases the latency another step:


MSI off
UDP ping pong 40 bytes	Test 1	Test 2	Test 3	Test 4
2.6.27		91.1725	91.31	91.17	91.12	91.09
2.6.28		91.5625	91.71	91.45	91.67	91.42
2.6.29		91.7	91.71	91.67	91.72	91.7
2.6.30-rc2	91.835	91.83	91.78	91.82	91.91

MSI on

UDP ping pong 40 bytes	Test 1	Test 2	Test 3	Test 4
2.6.22		83.1125	83.4	83.03	82.95	83.07
2.6.23		83.33	83.51	83.18	83.42	83.21
2.6.24		82.7775	82.8	82.77	82.77	82.77
2.6.25		85.875	85.94	85.75	86.06	85.75
2.6.26		87.4025	87.53	87.25	87.3	87.53
2.6.27		87.81	87.81	87.77	87.82	87.84
2.6.28		87.4275	87.77	87.24	87.28	87.42
2.6.29		88.4325	88.48	88.42	88.44	88.39
2.6.30-rc2	88.4925	88.49	88.44	88.56	88.48

Next test series will have always the same kernel on one side etc.


