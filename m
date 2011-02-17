From: "Vasanthy Kolluri (vkolluri)" <vkolluri@cisco.com>
Subject: RE: [net-next-2.6 PATCH 3/3] enic: Always use single transmit and single receive hardware queues per device
Date: Thu, 17 Feb 2011 14:45:56 -0800
Message-ID: <212AA327A3557741A058E787E06188730564B99A@xmb-sjc-219.amer.cisco.com>
References: <20110217185245.2476.60944.stgit@savbu-pc100.cisco.com><20110217185322.2476.10728.stgit@savbu-pc100.cisco.com> <20110217.141235.48514315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:7801 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752656Ab1BQWp6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 17:45:58 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20110217.141235.48514315.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Sorry for the short description.

We believe that our earlier patch for supporting multiple hardware
receive queues per enic device requires more internal testing. At this
point, we think that it's best to disable the use of multiple receive
queues. We believe that the current patch will provide an effective
means for the same.

Thanks
Vasanthy

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Thursday, February 17, 2011 2:13 PM
To: Vasanthy Kolluri (vkolluri)
Cc: netdev@vger.kernel.org
Subject: Re: [net-next-2.6 PATCH 3/3] enic: Always use single transmit
and single receive hardware queues per device

From: Vasanthy Kolluri <vkolluri@cisco.com>
Date: Thu, 17 Feb 2011 10:53:22 -0800

> From: Vasanthy Kolluri <vkolluri@cisco.com>
> 
> 
> 
> Signed-off-by: Christian Benvenuti <benve@cisco.com>
> Signed-off-by: Danny Guo <dannguo@cisco.com>
> Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: David Wang <dwang2@cisco.com>

You can't make a very serious change like this with such a terse commit
message, you have to explain exactly why this change is being made.
