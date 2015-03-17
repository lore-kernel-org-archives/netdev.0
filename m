From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v4] switchdev: fix stp update API to work with
 layered netdevices
Date: Tue, 17 Mar 2015 15:39:24 -0700
Message-ID: <5508AD1C.4000905@cumulusnetworks.com>
References: <1426527159-8039-1-git-send-email-roopa@cumulusnetworks.com> <55074A75.1080604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, sfeldma@gmail.com, jiri@resnulli.us,
	netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33420 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752081AbbCQWj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 18:39:27 -0400
Received: by pdnc3 with SMTP id c3so22649448pdn.0
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 15:39:26 -0700 (PDT)
In-Reply-To: <55074A75.1080604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/16/15, 2:26 PM, Florian Fainelli wrote:
> On 16/03/15 10:32, roopa@cumulusnetworks.com wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> make it same as the netdev_switch_port_bridge_setlink/dellink
>> api (ie traverse lowerdevs to get to the switch port).
>>
>> removes "WARN_ON(!ops->ndo_switch_parent_id_get)" because
>> direct bridge ports can be stacked netdevices (like bonds
>> and team of switch ports) which may not imeplement this ndo.
>>
>> v2 to v3:
>> 	- remove changes to bond and team. Bring back the
>> 	transparently following lowerdevs like i initially
>> 	had for setlink/getlink
>> 	(http://www.spinics.net/lists/netdev/msg313436.html)
>> 	dave and scott feldman also seem to prefer it be that
>> 	way and move to non-transparent way of doing things
>> 	if we see a problem down the lane.
>>
>> v3 to v4:
>> 	- fix ret initialization
> The changelog should be after "---" otherwise it will get included in
> the final git commit, we don't want that as this changelog only makes
> sense during the submission process.
>
ack, thanks..will fix it when i respin the patch.
