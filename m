From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH 0/2] Display adjacent switch port's attributes
Date: Thu, 12 Dec 2013 13:47:32 -0800
Message-ID: <52AA2EF4.70300@intel.com>
References: <1386768540-48188-1-git-send-email-raspl@linux.vnet.ibm.com> <20131211121357.4742d9e8@nehalam.linuxnetplumber.net> <52A9C0BE.5090801@linux.vnet.ibm.com> <20131212.122801.1249371766101769652.davem@davemloft.net> <52A9F7CD.5050904@intel.com> <CAGVrzcb47oUAn-5S=DpQkgPbMAwmBrfjUmfJroYiYX8mmRuORg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: raspl@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	blaschka@linux.vnet.ibm.com, netdev <netdev@vger.kernel.org>,
	linux-s390@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65005 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751496Ab3LLVrd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Dec 2013 16:47:33 -0500
In-Reply-To: <CAGVrzcb47oUAn-5S=DpQkgPbMAwmBrfjUmfJroYiYX8mmRuORg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>> Just to elaborate...
>>
>> Any application using lldp information will want to get events when
>> TLVs change. Maybe you can contrive ethtool to do this but its going to
>> be ugly. Netlink can support multicast events and applications can
>> register for them. Also netlink's TLV format matches nicely with LLDPs
>> TLV format.
>
> ethtool and netlink usually intersect for a few bits of information
> such as link status for instance. It is useful to have this
> information twice, with ethtool as a debugging aid, and via netlink to
> take appropriate actions.
>
> Maybe we just need to be clear on what needs to be present in ethtool
> only (configuration, static information) and see on a case-by-case
> what needs to be present in both ethtool and netlink?
>

OK if there is an enable/disable bit in ethtool that might make some
sense. Or an error flag that is helpful to have.

In this case we are dealing with peer attributes which are dynamic and
in my opinion should go into netlink and duplicating them in ethtool
although possible doesn't seem very useful to me.

.John
