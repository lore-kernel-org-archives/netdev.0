From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2 3/3] ip netns: Delete all netns
Date: Fri, 09 Jan 2015 15:24:02 +0100
Message-ID: <54AFE482.7020108@6wind.com>
References: <1420628662-9930-1-git-send-email-vadim4j@gmail.com>	<1420628662-9930-4-git-send-email-vadim4j@gmail.com>	<54AD5458.6000400@hp.com>	<20150107173640.GA19586@angus-think.lan>	<20150107181112.GA24241@angus-think.lan>	<54AD8BC3.2070609@hp.com>	<20150107195517.GA4645@angus-think.lan>	<20150109094315.0c370971@griffin> <CAMw6YJLx0O6dVnD2XcmF+qz+=m51TyZOqJWSYGKQ-XrMHP8z3w@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Brian Haley <brian.haley@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vadim Kochan <vadim4j@gmail.com>, Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:34925 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757188AbbAIOYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 09:24:06 -0500
Received: by mail-wg0-f53.google.com with SMTP id x13so8379444wgg.12
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 06:24:04 -0800 (PST)
In-Reply-To: <CAMw6YJLx0O6dVnD2XcmF+qz+=m51TyZOqJWSYGKQ-XrMHP8z3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/01/2015 10:54, Vadim Kochan a =C3=A9crit :
> Ok,
>
> If I will re-work to use new option, would it be useful ? So it will =
look:
>
>      $ ip -all netns del
>      $ ip -all netns exec ip link
>      $ ip -all netns exec ip route add ...
>
> Seems not so weird to me ?
What about making this new option only for the 'netns' subsystem?
Something like: 'ip netns -all exec'?


Regards,
Nicolas
