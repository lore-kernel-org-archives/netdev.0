From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC PATCH net-next] switchdev: don't abort hardware ipv4 fib
 offload on failure to program fib entry in hardware
Date: Tue, 5 May 2015 10:23:06 -0700
Message-ID: <CAE4R7bDudMzestBJ1OLah8Ea5_BXqNdcC9bqQ3L_Ek0B7=m99Q@mail.gmail.com>
References: <1430583883-3514-1-git-send-email-roopa@cumulusnetworks.com>
	<CAE4R7bCDG614esO1UByPYoX47+zzjr=Ed6LNPbqTKG7Nvnsm3A@mail.gmail.com>
	<5546EE05.1060206@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	john fastabend <john.fastabend@gmail.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Netdev <netdev@vger.kernel.org>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:36009 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755251AbbEERXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 13:23:06 -0400
Received: by qku63 with SMTP id 63so110543325qku.3
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 10:23:06 -0700 (PDT)
In-Reply-To: <5546EE05.1060206@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 3, 2015 at 8:56 PM, roopa <roopa@cumulusnetworks.com> wrote:
> On 5/3/15, 10:45 AM, Scott Feldman wrote:
>>
>> On Sat, May 2, 2015 at 9:24 AM,  <roopa@cumulusnetworks.com> wrote:
>>>
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> This basically removes the calls to netdev_switch_fib_ipv4_abort when
>>> there is an error in programming fib entry in hardware.

[cut]

> ack, I will post a full patch once we converge.

I'm OK with option a) for now.
