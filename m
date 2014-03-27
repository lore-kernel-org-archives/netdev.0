From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v2 net] vlan: Mask off vlan acceleration features on vlan
 device.
Date: Thu, 27 Mar 2014 16:25:41 -0400
Message-ID: <53348945.6070301@redhat.com>
References: <1395865521-2318-1-git-send-email-vyasevic@redhat.com>	<1395865711-3347-1-git-send-email-vyasevic@redhat.com> <20140327.151205.1227455812702138170.davem@davemloft.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31736 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755681AbaC0UZq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 16:25:46 -0400
In-Reply-To: <20140327.151205.1227455812702138170.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/27/2014 03:12 PM, David Miller wrote:
> From: Vlad Yasevich <vyasevic@redhat.com>
> Date: Wed, 26 Mar 2014 16:28:31 -0400
> 
>> Some drivers incorrectly assign vlan acceleration features to
>> vlan_features thus causing issues for Q-in-Q vlan configurations.
>> Prevent this once and for all by masking off acceleration features
>> for vlan devices until such time as we support stacked acceleration.
>>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> 
> Vlad, I've thought more about this, I'd rather we emit a warning so
> we can fix the drivers.
> 
> If they are setting the flags wrong, we probably want to go take a
> look to see if they are doing anything else related wrong too.
> 

OK.  I'll rework the patch to emit a warning.  I took a quick glance
through all the devices that set vlan_features and there are 3 more
the have vlan_features wrong.  I'll include those when I re-submit.

Thanks
-vlad
