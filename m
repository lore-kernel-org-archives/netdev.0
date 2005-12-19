From: Baruch Even <baruch@ev-en.org>
Subject: SACK performance improvements - technical report and updated
 2.6.6 patches
Date: Mon, 19 Dec 2005 20:26:54 +0000
Message-ID: <43A7178E.4030808@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Douglas Leith <d.leith@eee.strath.ac.uk>
Return-path: <end2end-interest-bounces@postel.org>
To: netdev@vger.kernel.org, end2end-interest@postel.org
List-Unsubscribe: <http://www.postel.org/mailman/listinfo/end2end-interest>,
	<mailto:end2end-interest-request@postel.org?subject=unsubscribe>
List-Archive: <http://www.postel.org/pipermail/end2end-interest>
List-Post: <mailto:end2end-interest@postel.org>
List-Help: <mailto:end2end-interest-request@postel.org?subject=help>
List-Subscribe: <http://www.postel.org/mailman/listinfo/end2end-interest>,
	<mailto:end2end-interest-request@postel.org?subject=subscribe>
Sender: end2end-interest-bounces@postel.org
Errors-To: end2end-interest-bounces@postel.org
List-Id: netdev.vger.kernel.org

Hello,

I wanted to post an update about my work for SACK performance
improvements, I've updated the patches on our website and added a
technical report on the work so far.

It can be found at:
http://hamilton.ie/net/research.htm#patches

In summary: The Linux stack so far is unable to effectively handle
single transfers on 1Gbps with high rtt links (220 ms rtt is what we
tested). The sender is unable to process the ACK packets fast enough
causing lost  ACKs and increased transfer times. Our work resulted in a
set of patches that enable the Linux TCP stack to handle this load
without breaking sweat.

Your comments on this work would be appreciated.

Regards,
Baruch
