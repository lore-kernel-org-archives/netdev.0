From: Madhu Challa <challa@noironetworks.com>
Subject: Re: [PATCH iproute2 net-next 2/2] Enable configuring multicast group
 join / leave at IP level.
Date: Mon, 16 Mar 2015 10:59:47 -0700
Message-ID: <CAN_zqfPPsZM9P6_WD6h2yrRHMajHac1xUeacsj_P-fTwugD7fg@mail.gmail.com>
References: <1425493810-2537-1-git-send-email-challa@noironetworks.com>
	<1425493810-2537-3-git-send-email-challa@noironetworks.com>
	<20150315124317.6a01a542@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35231 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932223AbbCPR7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 13:59:47 -0400
Received: by pabyw6 with SMTP id yw6so71432715pab.2
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 10:59:47 -0700 (PDT)
In-Reply-To: <20150315124317.6a01a542@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 15, 2015 at 12:43 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Wed,  4 Mar 2015 10:30:10 -0800
> Madhu Challa <challa@noironetworks.com> wrote:
>
>> Joining multicast group on ethernet level via "ip maddr" command would
>> not work if we have an Ethernet switch that does igmp snooping since
>> the switch would not replicate multicast packets on ports that did not
>> have IGMP reports for the multicast addresses.
>>
>> Linux vxlan interfaces created via "ip link add vxlan" have the group option
>> that enables then to do the required join.
>>
>> By extending ip address command with option "autojoin" we can get similar
>> functionality for openvswitch vxlan interfaces as well as other tunneling
>> mechanisms that need to receive multicast traffic.
>>
>> example:
>> ip address add 224.1.1.10/24 dev eth5 autojoin
>> ip address del 224.1.1.10/24 dev eth5
>
> Applied, but please update manual pages as well.

Thanks Stephen. Sure I will.

Thanks.
