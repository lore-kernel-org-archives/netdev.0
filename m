From: Ben Greear <greearb@candelatech.com>
Subject: Re: RTM_NEWLINK not received by application when connecting multiple
 devices simultaneously
Date: Thu, 19 Apr 2012 07:26:22 -0700
Message-ID: <4F90208E.6070201@candelatech.com>
References: <CAKfDRXj+mydkzNFC8q2aE_JWHp3ie0cijC-itkm6sHLuZr98Fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34025 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753758Ab2DSO0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 10:26:24 -0400
In-Reply-To: <CAKfDRXj+mydkzNFC8q2aE_JWHp3ie0cijC-itkm6sHLuZr98Fw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2012 04:44 AM, Kristian Evensen wrote:
> Hello,

> The application works as intended when I connect interfaces one by
> one. However, if I connect two interfaces "simultaneously", the
> RTM_NEWLINK message for one of the interfaces is sometimes not
> received. Nothing arrives at the handle. It seems to be random which
> RTM_NEWLINK actually arrives. I have only been able to recreate this
> problem when connecting two USB 3G modems and automatically dialing
> the ISP, but I assume it would happen with other technologies as well.
> What puzzles me, is that both RTM_NEWLINK messages are seen by for
> example ip monitor. This has led me to conclusion that there is a bug
> in my application, and my question is therefore, are there any common
> mistakes one can make or things to forget that would cause a message
> to get lost or not be received, or does anyone have any tips on where
> I can start looking?

Multiple netlink msgs can be received in each read of a netlink
socket.  Maybe you are only processing the first one?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
