From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH RFC 0/5] net: L2 only interfaces
Date: Tue, 25 Aug 2015 16:52:18 -0700
Message-ID: <55DCFFB2.1030100@cumulusnetworks.com>
References: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com> <CACP96tSxYyWUhAeXTzc49P4Wk3Lr6mr1MMm_7pZQoK4iEdQ5sg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, andrew@lunn.ch,
	linux@roeck-us.net,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	sfeldma@gmail.com
To: Sowmini Varadhan <sowmini05@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34252 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896AbbHYXwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 19:52:20 -0400
Received: by pabzx8 with SMTP id zx8so48743004pab.1
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 16:52:20 -0700 (PDT)
In-Reply-To: <CACP96tSxYyWUhAeXTzc49P4Wk3Lr6mr1MMm_7pZQoK4iEdQ5sg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/25/15 4:44 PM, Sowmini Varadhan wrote:
> On Tue, Aug 25, 2015 at 3:50 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> Hi all,
>>
>> This patch series implements a L2 only interface concept which basically denies
>> any kind of IP address configuration on these interfaces, but still allows them
>> to be used as configuration end-points to keep using ethtool and friends.
>>
>
> This is a very interesting idea. A few questions/thoughts: will there
> be any eventual restrictions on which types interfaces can be L2_ONLY?
> Ideally, it should be possible to let interfaces wink in/out of L2 only
> state administratively (as can be done on a typical router, after unwinding
> existing config as needed)
>
> I'm assuming something will prevent an L2-only interface from being
> part of a vrf.

The VRF driver can check the device when the enslave request happens.
