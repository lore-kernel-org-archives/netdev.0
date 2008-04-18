From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 4/5] [E1000]: [VLAN] Turn off the HW vlan filter if promisc
Date: Fri, 18 Apr 2008 10:48:19 -0700
Message-ID: <4808DEE3.4070203@intel.com>
References: <20080411135851.GD8137@tp64> <4807C03E.7060705@intel.com> <b25c3fa70804171854s7b056da1u89e9b758c494a07@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, jeff@garzik.org, netdev@vger.kernel.org
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50379 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758750AbYDRRtW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2008 13:49:22 -0400
In-Reply-To: <b25c3fa70804171854s7b056da1u89e9b758c494a07@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joonwoo Park wrote:
> 2008/4/18, Kok, Auke <auke-jan.h.kok@intel.com>:
>> My logistical objection against this patch is that it adjusts only one/two drivers
>> to do something, but I don't see anything consistently in all the drivers at all
>> that suggest that this is the right thing to do at all. Either a mandate or
>> something suggesting that all drivers that do vlan filtering *should* do something
>>  specific in promiscuous mode.
> 
> It's true. We need to fix all the netdev which is VLAN_HW_FILTER capable IMHO.
> However I couldn't make patches for all of them since I don't have those HW :(

sigh, we really should not make e1000(e) guinea pigs - especially at this time.

is there someone who can actually test this for us? I'd be a lot happier if I had
some confidence that people who actually do use promisc/vlans give me a thumbs up.


Auke


