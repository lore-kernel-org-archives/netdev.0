From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC PATCHv2 bridge 7/7] bridge:  Add the ability to show dump
 the vlan map from a bridge port
Date: Mon, 24 Sep 2012 09:48:27 -0400
Message-ID: <506064AB.4020708@redhat.com>
References: <1348058536-22607-1-git-send-email-vyasevic@redhat.com>  <1348058536-22607-8-git-send-email-vyasevic@redhat.com> <1348334132.2521.100.camel@bwh-desktop.uk.solarflarecom.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21262 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754196Ab2IXNsb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 09:48:31 -0400
In-Reply-To: <1348334132.2521.100.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/2012 01:15 PM, Ben Hutchings wrote:
> On Wed, 2012-09-19 at 08:42 -0400, Vlad Yasevich wrote:
>> Using the RTM_GETLINK dump the vlan map of a given bridge port.
> [...]
>
> This enlarges the RTM_GETLINK response quite a bit.  I think perhaps
> this should be optional, like IFLA_VFINFO_LIST is now.
>
> Ben.
>

Only for AF_BRIDGE and only if VLANs are set.  I guess I could add
a filter option similar to VFINFO as well, if you think that's necessary.

-vlad
