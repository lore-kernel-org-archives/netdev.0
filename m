From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] switchdev: change BUG_ON to WARN for attr set
 failure case
Date: Wed, 17 Jun 2015 15:38:47 -0700
Message-ID: <CAE4R7bC4-prxLhafcgv-ruEK2Ya3mZxFkCnrxEEP8AUriiKrzw@mail.gmail.com>
References: <1434046842-24601-1-git-send-email-sfeldma@gmail.com> <20150611.162724.1330335369043090316.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	David Ahern <dsahern@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:33205 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752059AbbFQWjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 18:39:08 -0400
Received: by oiyy130 with SMTP id y130so28057857oiy.0
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 15:39:08 -0700 (PDT)
In-Reply-To: <20150611.162724.1330335369043090316.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 11, 2015 at 4:27 PM, David Miller <davem@davemloft.net> wrote:
> From: sfeldma@gmail.com
> Date: Thu, 11 Jun 2015 11:20:42 -0700
>
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> This particular BUG_ON condition was checking for attr set err in the
>> COMMIT phase, which isn't expected (it's a driver bug if PREPARE phase is
>> OK but COMMIT fails).  But BUG_ON() is too strong for this case, so change
>> to WARN().  BUG_ON() would be warranted if the system was corrupted beyond
>> repair, but this is not the case here.
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>
> Applied, thanks Scott.

I think this one slipped thru the cracks.  I'm not seeing it in net-next.
