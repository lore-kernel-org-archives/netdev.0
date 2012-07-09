From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH] net/fsl_pq_mdio: use spin_event_timeout() to poll the
 indicator register
Date: Mon, 09 Jul 2012 21:50:46 +0200
Message-ID: <4FFB3616.2070403@computer.org>
References: <1341357381-10861-1-git-send-email-timur@freescale.com> <20120708.235926.1117975937932919247.davem@davemloft.net> <4FFAEB44.2030600@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Fleming Andy-AFLEMING <afleming@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tabi Timur-B04825 <B04825@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay007.isp.belgacom.be ([195.238.6.173]:19977 "EHLO
	mailrelay007.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752722Ab2GITvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 15:51:14 -0400
In-Reply-To: <4FFAEB44.2030600@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/09/2012 04:31 PM, Tabi Timur-B04825 wrote:
>> This indentation is absolutely terrible.
> 
> Can you give me a clue as to how you think it should look?  I could not 
> come up with a good way to break up these lines and keep them under 80 
> characters.
> 

How about this:

+	status = spin_event_timeout(!(in_be32(&regs->miimind) &	MIIMIND_BUSY),
+				    1000, 0);

On the second line use as many tabs as possible, then continue with spaces until the '1' in 1000 lines up with the '!'.

HTH, Jan
