From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH v3 3/8] net: add fdb generic dump routine
Date: Sun, 15 Apr 2012 09:05:59 -0700
Message-ID: <4F8AF1E7.2030306@intel.com>
References: <20120412170258.2717.34628.stgit@jf-dev1-dcblab>  <20120412170702.2717.81539.stgit@jf-dev1-dcblab> <1334262009.2497.20.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, mst@redhat.com, davem@davemloft.net,
	sri@us.ibm.com, hadi@cyberus.ca, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gregory.v.rose@intel.com,
	krkumar2@in.ibm.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55877 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754734Ab2DOQGA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Apr 2012 12:06:00 -0400
In-Reply-To: <1334262009.2497.20.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/12/2012 1:20 PM, Ben Hutchings wrote:
> On Thu, 2012-04-12 at 10:07 -0700, John Fastabend wrote:
>> This adds a generic dump routine drivers can call. It
>> should be sufficient to handle any bridging model that
>> uses the unicast address list. This should be most SR-IOV
>> enabled NICs.
>>
>> v2: return error on nlmsg_put and use -EMSGSIZE instead
>>     of -ENOMEM this is inline other usages
> 
> It's still not propagated up to ndo_dflt_fdb_dump() though:
> 

Thanks Ben. I'll fix this in v4.
