From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 09 Oct 2007 15:04:23 -0400
Message-ID: <470BD0B7.4070607@garzik.org>
References: <D5C1322C3E673F459512FB59E0DDC32903BC14AC@orsmsx414.amr.corp.intel.com>	<1191886845.4373.138.camel@localhost>	<470AD5D7.1070000@garzik.org> <20071008.184126.124062865.davem@davemloft.net> <470AE373.9020207@garzik.org> <D5C1322C3E673F459512FB59E0DDC32903C0821A@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	krkumar2@in.ibm.com, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	mcarlson@broadcom.com, mchan@broadcom.com,
	general@lists.openfabrics.org, tgraf@suug.ch,
	randy.dunlap@oracle.com, sri@us.ibm.com
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60221 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752265AbXJITFB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 15:05:01 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32903C0821A@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>> IMO the net driver really should provide a hint as to what it wants.
>>
>> 8139cp and tg3 would probably prefer multiple TX queue 
>> behavior to match silicon behavior -- strict prio.
> 
> If I understand what you just said, I disagree.  If your hardware is
> running strict prio, you don't want to enforce strict prio in the qdisc
> layer; performing two layers of QoS is excessive, and may lead to
> results you don't want.  The reason I added the DRR qdisc is for the Si
> that has its own queueing strategy that is not RR.  For Si that
> implements RR (like e1000), you can either use the DRR qdisc, or if you
> want to prioritize your flows, use PRIO.

A misunderstanding, I think.

To my brain, DaveM's item #2 seemed to assume/require the NIC hardware 
to balance fairly across hw TX rings, which seemed to preclude the 
8139cp/tg3 style of strict-prio hardware.  That's what I was responding to.

As long as there is some modular way to fit 8139cp/tg3 style multi-TX 
into our universe, I'm happy :)

	Jeff



