From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH v2 1/3] net: create generic bridge ops
Date: Fri, 02 Nov 2012 16:46:10 -0700
Message-ID: <50945B42.4000502@intel.com>
References: <20121024181033.14378.33097.stgit@jf-dev1-dcblab>  <20121024181257.14378.41548.stgit@jf-dev1-dcblab> <1351895575.2703.5.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, buytenh@wantstofly.org, davem@davemloft.net,
	vyasevic@redhat.com, jhs@mojatatu.com, chrisw@redhat.com,
	krkumar2@in.ibm.com, samudrala@us.ibm.com,
	peter.p.waskiewicz.jr@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gregory.v.rose@intel.com,
	eilong@broadcom.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:3190 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760021Ab2KBXq3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Nov 2012 19:46:29 -0400
In-Reply-To: <1351895575.2703.5.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/2/2012 3:32 PM, Ben Hutchings wrote:
> On Wed, 2012-10-24 at 11:12 -0700, John Fastabend wrote:
>> The PF_BRIDGE:RTM_{GET|SET}LINK nlmsg family and type are
>> currently embedded in the ./net/bridge module. This prohibits
>> them from being used by other bridging devices. One example
>> of this being hardware that has embedded bridging components.
>>
>> In order to use these nlmsg types more generically this patch
>> adds two net_device_ops hooks. One to set link bridge attributes
>> and another to dump the current bride attributes.
>>
>> 	ndo_bridge_setlink()
>> 	ndo_bridge_getlink()
> [...]
>
> Do you have any userland code for this?

Just sent this to netdev. Or you can pull it here,

git://github.com/jrfastab/net-next-iproute2-jf.git


I'll test your idx fix now.
