From: Rakesh Ranjan <rakesh@chelsio.com>
Subject: Re: [RFC-PATCH] dhcp provisioning support in cxgb3i
Date: Fri, 30 Oct 2009 10:54:00 +0530
Message-ID: <4AEA7870.4010804@chelsio.com>
References: <4AE995C4.4080909@chelsio.com> <4AEA04A4.1060800@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, James Bottomley <James.Bottomley@suse.de>,
	Karen Xie <kxie@chelsio.com>,
	"open-iscsi@googlegroups.com" <open-iscsi@googlegroups.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	netdev@vger.kernel.org
To: Mike Christie <michaelc@cs.wisc.edu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755342AbZJ3FYR@vger.kernel.org>
In-Reply-To: <4AEA04A4.1060800@cs.wisc.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mike Christie wrote:
> Rakesh Ranjan wrote:
>> Hi Mike,
>>
>> Herein attached patches for having dhcp provisioning support in 
>> cxgb3i. I have added one new iscsi netlink message 
>> ISCSI_UEVENT_REQ_IPCONF. 
> 
> Is the idea to have iscsid/uip send down this msg?
> 
> Was it not possible to hook in more like how bnx2i does dhcp?

yep, idea is to have iscsid send down ISCSI_UEVENT_REQ_IPCONF msg. bnx2i 
approach in our case for at least T3 is not feasible.

Regards
Rakesh Ranjan
