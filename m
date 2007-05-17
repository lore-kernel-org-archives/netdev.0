From: Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>
Subject: Re: [IPV4] LVS: Allow to send ICMP unreachable responses when real-servers
 are removed
Date: Thu, 17 May 2007 13:25:53 +0200
Message-ID: <464C3BC1.8090908@tis.icnet.pl>
References: <200704271705.l3RH5Brw026873@hera.kernel.org> <4648382E.8030009@trash.net> <20070514.033504.48528120.davem@davemloft.net> <4648714E.9050200@tis.icnet.pl> <464872E2.2030502@trash.net> <464884EE.3030606@tis.icnet.pl> <46489F5C.4000801@trash.net> <20070515052608.GG13708@verge.net.au> <4649DBB7.3070608@trash.net> <Pine.LNX.4.58.0705160012470.2626@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Simon Horman <horms@verge.net.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from d1.icnet.pl ([212.160.220.21]:33053 "EHLO d1.icnet.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755024AbXEQL0H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2007 07:26:07 -0400
In-Reply-To: <Pine.LNX.4.58.0705160012470.2626@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Julian Anastasov wrote:
> If icmp_send is changed to use inet_addr_type() then ICMP will leave
> with saddr != VIP and that is not nice.
> ...
>> I'm not familiar with the IPVS terms, but as far as I understand,
>> it is _not_ going to return RTN_LOCAL, so we get the desired
>> behaviour of selecting a local address as source.
> 
> 	But what is preferred is to use VIP in ICMP.
> 
> ip route add local VIP dev lo table user_defined
> 
> 	returns RTCF_LOCAL but inet_addr_type() does not return RTN_LOCAL,
> we fix one thing but break another :)

Well, I have promissed you to give some feedback after I test the patch 
proposed by Patrick, but after Julian's post I can only confirm that it 
works exactly as Julian said, what is not what I would expect.

Julian, thank you for your detailed explanation of the issue, I have 
nothing more to add.

Janusz


