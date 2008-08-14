From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Wed, 13 Aug 2008 21:44:33 -0500
Message-ID: <48A39C11.4010506@opengridcomputing.com>
References: <48A389DB.9050002@opengridcomputing.com>	<20080813.183755.72334968.davem@davemloft.net>	<48A38FEF.6090500@opengridcomputing.com> <20080813.190521.224523380.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tom@opengridcomputing.com, rdreier@cisco.com, rick.jones2@hp.com,
	jgarzik@pobox.com, divy@chelsio.com, kxie@chelsio.com,
	netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	michaelc@cs.wisc.edu, daisyc@us.ibm.com, wenxiong@us.ibm.com,
	bhua@us.ibm.com, dm@chelsio.com, leedom@chelsio.com,
	linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20080813.190521.224523380.davem@davemloft.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> I've stated clearly what the base requirement is, which is that the
> packet is fully processed by the networking stack and that the card
> merely does data placement optimizations that the stack can completely
> ignore if it wants to.
>
> You have an entire engine in there that can interpret an iSCSI
> transport stream, you have the logic to do these kinds of things,
> and it can be done without managing the connection on the card.
>   

Thanks for finally stating it clearly.

