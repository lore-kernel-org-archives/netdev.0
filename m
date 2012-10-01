From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv6 net-next] vxlan: virtual extensible lan
Date: Mon, 01 Oct 2012 18:34:09 -0400 (EDT)
Message-ID: <20121001.183409.1653466880556747560.davem@davemloft.net>
References: <20121001135719.16062ccb@nehalam.linuxnetplumber.net>
	<20121001.180712.1525189650240917302.davem@davemloft.net>
	<20121001153014.07d25c4e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, chrisw@redhat.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41844 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609Ab2JAWeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 18:34:13 -0400
In-Reply-To: <20121001153014.07d25c4e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 1 Oct 2012 15:30:14 -0700

> On Mon, 01 Oct 2012 18:07:12 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Stephen Hemminger <shemminger@vyatta.com>
>> Date: Mon, 1 Oct 2012 13:57:19 -0700
>> 
>> > This is an implementation of Virtual eXtensible Local Area Network
>> > as described in draft RFC:
>> >   http://tools.ietf.org/html/draft-mahalingam-dutt-dcops-vxlan-02
>> > 
>> > The driver integrates a Virtual Tunnel Endpoint (VTEP) functionality
>> > that learns MAC to IP address mapping. 
>> > 
>> > This implementation has only been tested with the user-mode TAP
>> > based version for Linux, not against other vendors (yet).
>> > 
>> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>> 
>> It doesn't build.
>> 
>> And I'm not telling you what the build error is, you'll have to do an
>> allmodconfig build yourself to see it.
>> 
>> I want you to get into the habit of doing an allmodconfig build to
>> validate your changes because that's the very first thing I'm going to
>> do.
> 
> Dave did you remember to include the two pre-cursor patches.
> 
> Vxlan was originally submitted as a 3 part series and only the
> last one ever changed.
> 
>  [PATCH net-next 1/3] netlink: add attributes to fdb interface
>  [PATCH net-next 2/3] igmp: export symbol ip_mc_leave_group
> 
> Make allmodconfig works for me (x86-64).

You MUST always resubmit the entire series when you resubmit one
patch.

Furthermore you confused the situation even more by not including
the patch number information in your Subject line.
