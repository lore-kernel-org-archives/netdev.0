From: Gagan Arneja <gagan@vmware.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 13:25:19 -0700
Message-ID: <46437FAF.50004@vmware.com>
References: <OF305F038C.A48D4C37-ON652572D7.00538ECA-652572D7.00546E39@in.ibm.com> <46435412.50800@hp.com> <1178820423.17393.3.camel@w-sridhar2.beaverton.ibm.com> <464375F9.1050600@gmail.com> <1178827887.4062.90.camel@localhost> <46437D53.7000209@gmail.com> <1178828480.4062.98.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gagan Arneja <gaagaan@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Rick Jones <rick.jones2@hp.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.113.40.141]:35623 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755383AbXEJUZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 16:25:20 -0400
In-Reply-To: <1178828480.4062.98.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> For example:
> my biggest challenge with the e1000 was just hacking up the DMA setup
> path - i seem to get better numbers if i dont kick the DMA until i stash
> all the packets on the ring first etc. It seemed counter-intuitive.

That seems to make sense. The rings are(?) in system memory and you can 
write to them faster. Kicking the DMA needs a transaction on the PCI 
bus, which can be painfully slow...

--
Gagan
