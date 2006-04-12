From: Roberto Nibali <ratz@drugphish.ch>
Subject: Re: [PATCH] shutting down an interface should remove ipv4 addresses
Date: Wed, 12 Apr 2006 23:38:01 +0200
Message-ID: <443D7339.2040700@drugphish.ch>
References: <Pine.LNX.4.58.0604110828390.10538@localhost>	<20060411.005625.91443294.davem@davemloft.net>	<Pine.LNX.4.58.0604111004040.10538@localhost> <20060411.013503.04535700.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: koszik@atw.hu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drugphish.ch ([69.55.226.176]:1174 "EHLO www.drugphish.ch")
	by vger.kernel.org with ESMTP id S932320AbWDLViL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2006 17:38:11 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060411.013503.04535700.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: Matyas Koszik <koszik@atw.hu>
> Date: Tue, 11 Apr 2006 10:08:01 +0200 (CEST)
> 
>> Then it maybe shouldn't affect the flow of packets while the
>> interface is down - or is it also something people depend on?
> 
> Yes, people probably do depend upon it.

Not that my voice weights in too much, but I should like to note that 
our network and firewall setup depends on this behaviour since the early 
2.2.x kernel releases.

2-stage network setup (address assignment and link state) is very much 
to our liking :). I would not be too thrilled to change that again.

Best regards,
Roberto Nibali, ratz
-- 
echo 
'[q]sa[ln0=aln256%Pln256/snlbx]sb3135071790101768542287578439snlbxq' | dc
