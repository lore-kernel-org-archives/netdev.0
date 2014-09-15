From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [Bridge] [PATCH 2/3] bridge: Add filtering support for default_pvid
Date: Mon, 15 Sep 2014 11:09:17 -0400
Message-ID: <5417011D.2000301@redhat.com>
References: <1410554691-18467-1-git-send-email-vyasevic@redhat.com> <1410554691-18467-3-git-send-email-vyasevic@redhat.com> <5415B27A.2000508@gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, bridge@lists.linux-foundation.org
To: Toshiaki Makita <toshiaki.makita1@gmail.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29968 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753741AbaIOPJX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2014 11:09:23 -0400
In-Reply-To: <5415B27A.2000508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/14/2014 11:21 AM, Toshiaki Makita wrote:
> (14/09/13 (土) 5:44), Vladislav Yasevich wrote:
>> Currently when vlan filtering is turned on on the bridge, the bridge
>> will drop all traffic untill the user configures the filter.  This
>> isn't very nice for ports that don't care about vlans and just
>> want untagged traffic.
>>
>> A concept of a default_pvid was recently introduced.  This patch
>> adds filtering support for default_pvid.   Now, ports that don't
>> care about vlans and don't define there own filter will belong
>> to the VLAN of the default_pvid and continue to receive untagged
>> traffic.
> 
> If user sets pvid, then vid 1 (default_pvid) will become non-pvid but
> still not be filtered, right?

Right.

> vlan_bitmap of default_pvid shouldn't be cleared on setting pvid?

I can see arguments for both.  Just because the user wishes to set a
different pvid may not always mean that vlan associated with default pvid
shouldn't be filtered.  I think it's at user's discretion.  I hesitate
to do too many things automatically.

-vlad
> 
> Thanks,
> Toshiaki Makita
> 
