From: annie li <annie.li@oracle.com>
Subject: Re: [PATCH 1/1] xen/netback: correctly calculate required slots of
 skb.
Date: Wed, 10 Jul 2013 16:34:50 +0800
Message-ID: <51DD1CAA.7060908@oracle.com>
References: <1373350520-19985-1-git-send-email-annie.li@oracle.com> <20130709161612.GF19798@zion.uk.xensource.com> <51DCC795.2070806@oracle.com> <20130710074851.GH19798@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	Ian.Campbell@citrix.com, konrad.wilk@oracle.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23141 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753460Ab3GJIe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 04:34:27 -0400
In-Reply-To: <20130710074851.GH19798@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-7-10 15:48, Wei Liu wrote:
> On Wed, Jul 10, 2013 at 10:31:49AM +0800, annie li wrote:
> [...]
>>> This seems to differ from netbk_gop_frag_copy. In that function it's
>>> like
>>>
>>>      if (*head && skb_shinfo(skb)->gso_size && !vif->gso_prefix)
>> I mixed netbk_gop_frag_copy and xen_netbk_count_skb_slots just now,
>> so please ignore the comments here in my last email.
>> In xen_netbk_count_skb_slots, we have following code already, so it
>> is not necessary to add gso condition here.
>>
>>          if (skb_shinfo(skb)->gso_size)
>>                  count++;
>>
> Oh I see. But the condition still seems to be different from the
> original one -- you missed !vif->gso_prefix.

The original code in xen_netbk_count_skb_slots does not have 
!vif->gso_prefix. But I think you are right, it is better to keep 
consistent with that in netbk_gop_frag_copy.

Thanks
Annie
