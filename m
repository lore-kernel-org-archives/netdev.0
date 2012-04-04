From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next 3/4] team: add binary option type
Date: Thu, 5 Apr 2012 00:14:47 +0200
Message-ID: <20120404221446.GA2404@minipsycho>
References: <1333227682-10235-4-git-send-email-jpirko@redhat.com>
 <20120403.183816.230619298656469157.davem@davemloft.net>
 <20120404122930.GD2202@minipsycho.brq.redhat.com>
 <20120404.174547.1002799463139854012.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	raise.sail@gmail.com, nuno.martins@caixamagica.pt, matt@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26829 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756979Ab2DDWOz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 18:14:55 -0400
Content-Disposition: inline
In-Reply-To: <20120404.174547.1002799463139854012.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 04, 2012 at 11:45:47PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jpirko@redhat.com>
>Date: Wed, 4 Apr 2012 14:29:31 +0200
>
>> Wed, Apr 04, 2012 at 12:38:16AM CEST, davem@davemloft.net wrote:
>>>From: Jiri Pirko <jpirko@redhat.com>
>>>Date: Sat, 31 Mar 2012 23:01:21 +0200
>>>
>>>> For transfering generic binary data (e.g. BPF code), introduce new
>>>> binary option type.
>>>> 
>>>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>>
>>>Several issues:
>>>
>>>> +		struct team_option_binary tbinary;
>>>
>>>You put this into a netlink attribute, it has a non-fixed
>>>type size because it uses pointer.  A compat task will do
>>>the wrong thing and you won't interpret it's attribute
>>>correctly.
>> 
>> I'm not nla_putting struct team_option_binary tbinary. I'm putting only
>> the data on what the pointer stored into that points (tbinary.data):
>> 
>> nla_put(skb, TEAM_ATTR_OPTION_DATA, tbinary.data_len, tbinary.data));
>
>Aha, I misread, thanks for explaining.

Going to repost 3/4 and 4/4.
