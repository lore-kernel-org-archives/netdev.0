From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH] net: rocker: Add basic netdev counters - v2
Date: Fri, 16 Jan 2015 16:08:03 -0800
Message-ID: <CAE4R7bDrsA9xD=Bin8TTWzvH2XouaJ_crGvaHs2RuFEEgjAGJA@mail.gmail.com>
References: <1421443349-77718-1-git-send-email-dsahern@gmail.com>
	<CAE4R7bA3QG4LDvVQywDsRuJzJYv4mBq3=OXi2L=qGDfa4a8ykw@mail.gmail.com>
	<54B9A36B.1050204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:36807 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751909AbbAQAIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 19:08:05 -0500
Received: by mail-we0-f179.google.com with SMTP id m14so1104657wev.10
        for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 16:08:04 -0800 (PST)
In-Reply-To: <54B9A36B.1050204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 16, 2015 at 3:48 PM, David Ahern <dsahern@gmail.com> wrote:
> On 1/16/15 4:41 PM, Scott Feldman wrote:
>>
>>
>> Thanks David.  I think this is good enough for first pass.  Longer
>> term, I'd like to see this replaced by stats read from device for each
>> port.
>
>
> Aren't there 2 sets of stats at play here?
> 1. packets punted to the control plane / CPU,
> 2. packets forwarded through the ports.

You're right.

> If you have the netdev counters resemble packets handled through the port it
> could be confusing to someone looking at packets handled by the OS.

Agreed, keep traditional netdev stats for pkts to/from OS.  Maybe
we're done then?

> What about having detailed counters local to the driver (i.e., ethtool -S)
> show the low level stats like packets handled through the port?

That sounds perfect, to use ethtool -S for extended device stats.
