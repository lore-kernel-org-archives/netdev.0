From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH iproute2] route: label externally offloaded routes
Date: Sun, 15 Mar 2015 13:08:56 -0700
Message-ID: <CAE4R7bDSA4yRe94wW3AO0+2-Gd7xoukjRs=krvnBnBL=rwZswg@mail.gmail.com>
References: <1425795335-6416-1-git-send-email-sfeldma@gmail.com>
	<20150315123922.4c49291c@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f176.google.com ([209.85.216.176]:36463 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbbCOUI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 16:08:56 -0400
Received: by qcto4 with SMTP id o4so28240257qct.3
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 13:08:56 -0700 (PDT)
In-Reply-To: <20150315123922.4c49291c@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 15, 2015 at 12:39 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Sat,  7 Mar 2015 22:15:35 -0800
> sfeldma@gmail.com wrote:
>
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> On ip route print dump, label externally offloaded routes with "external".
>> Offloaded routes are flagged with RTNH_F_EXTERNAL, a recent additon to
>> net-next.  For example:
>>
>> $ ip route
>> default via 192.168.0.2 dev eth0
>> 11.0.0.0/30 dev swp1  proto kernel  scope link  src 11.0.0.2 external
>> 11.0.0.4/30 via 11.0.0.1 dev swp1  proto zebra  metric 20 external
>> 11.0.0.8/30 dev swp2  proto kernel  scope link  src 11.0.0.10 external
>> 11.0.0.12/30 via 11.0.0.9 dev swp2  proto zebra  metric 20 external
>> 12.0.0.2  proto zebra  metric 30 external
>>         nexthop via 11.0.0.1  dev swp1 weight 1
>>         nexthop via 11.0.0.9  dev swp2 weight 1
>> 12.0.0.3 via 11.0.0.1 dev swp1  proto zebra  metric 20 external
>> 12.0.0.4 via 11.0.0.9 dev swp2  proto zebra  metric 20 external
>> 192.168.0.0/24 dev eth0  proto kernel  scope link  src 192.168.0.15
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>
> Applied to net-next branch of iproute2

Oops, sorry Stephan, I just sent a v2 with a change to the label.  Can
you apply that version?

> All iproute2 commands should be invertable.
> If you show something you need to accept that as input.
>  Please fix that.

Working on it.
