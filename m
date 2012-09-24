From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC PATCHv2 bridge 7/7] bridge: Add the ability to show dump
 the vlan map from a bridge port
Date: Mon, 24 Sep 2012 09:49:52 -0400
Message-ID: <50606500.1040102@redhat.com>
References: <1348058536-22607-1-git-send-email-vyasevic@redhat.com> <1348058536-22607-8-git-send-email-vyasevic@redhat.com> <1348334132.2521.100.camel@bwh-desktop.uk.solarflarecom.com> <20120922.132747.1937291269030903700.davem@davemloft.net> <20120922130553.3d7e0299@nehalam.linuxnetplumber.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40607 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754196Ab2IXNt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 09:49:57 -0400
In-Reply-To: <20120922130553.3d7e0299@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/2012 04:05 PM, Stephen Hemminger wrote:
> On Sat, 22 Sep 2012 13:27:47 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
>
>> From: Ben Hutchings <bhutchings@solarflare.com>
>> Date: Sat, 22 Sep 2012 18:15:32 +0100
>>
>>> On Wed, 2012-09-19 at 08:42 -0400, Vlad Yasevich wrote:
>>>> Using the RTM_GETLINK dump the vlan map of a given bridge port.
>>> [...]
>>>
>>> This enlarges the RTM_GETLINK response quite a bit.  I think perhaps
>>> this should be optional, like IFLA_VFINFO_LIST is now.
>>
>> Completely agreed.
>
> Since most users won't use it, it should be not necessary to include
> it if the map is blank.
>

Response is included only for AF_BRIDGE calls (proably used by STP 
implementation) and only when vlan filtering is configured.

I do see the point though and can add a filter for this.

-vlad
