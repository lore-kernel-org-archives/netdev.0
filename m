From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH 4/4] net_sched: add MQSAFE flag to qdisc
 to identify mq like qdiscs
Date: Tue, 21 Dec 2010 11:21:46 -0800
Message-ID: <4D10FE4A.6090301@intel.com>
References: <20101217153439.12170.39538.stgit@jf-dev1-dcblab>	 <20101217153456.12170.17327.stgit@jf-dev1-dcblab> <1292887321.3055.43.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hadi@cyberus.ca" <hadi@cyberus.ca>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:37917 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751799Ab0LUTVv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Dec 2010 14:21:51 -0500
In-Reply-To: <1292887321.3055.43.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2010 3:22 PM, Ben Hutchings wrote:
> On Fri, 2010-12-17 at 07:34 -0800, John Fastabend wrote:
>> Add a MQSAFE flag to the qdisc schedulers that can be safely
>> managed by sch_mclass. Without this flag schedulers that are
>> not aware of multiple tx queues can be grafted under the
>> mclass qdisc. Allowing incorrect qdiscs to be grafted causes
>> an invalid mapping from qdisc's to netdevice queues.
> [...]
> 
> This should be defined before adding sch_mclass, or at the same time,
> not after.
> 
> Ben.
> 

Right. I'll roll it into the initial mclass patch. Thanks.
