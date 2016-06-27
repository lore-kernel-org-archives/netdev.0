From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH v4 00/19] CALIPSO Implementation
Date: Mon, 27 Jun 2016 15:29:46 -0400
Message-ID: <CAHC9VhSPat1Um-bGFBFO2pVh-6XJqih4HjbMs589wA-cS15bUw@mail.gmail.com>
References: <1466429819-12707-1-git-send-email-huw@codeweavers.com>
 <20160621.053928.1340819307282355897.davem@davemloft.net> <20160621095548.GA19213@merlot.physics.ox.ac.uk>
 <20160623.152112.1146976941740701983.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, Paul Moore <pmoore@redhat.com>
To: huw@codeweavers.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:33756 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362AbcF0T3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 15:29:47 -0400
Received: by mail-oi0-f50.google.com with SMTP id u201so214357102oie.0
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 12:29:47 -0700 (PDT)
In-Reply-To: <20160623.152112.1146976941740701983.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 23, 2016 at 3:21 PM, David Miller <davem@davemloft.net> wrote:
> From: Huw Davies <huw@codeweavers.com>
> Date: Tue, 21 Jun 2016 10:55:48 +0100
>
>> On Tue, Jun 21, 2016 at 05:39:28AM -0400, David Miller wrote:
>>> From: Huw Davies <huw@codeweavers.com>
>>> Date: Mon, 20 Jun 2016 14:36:40 +0100
>>>
>>> > This patch series implements RFC 5570 - Common Architecture Label IPv6
>>> > Security Option (CALIPSO).  Its goal is to set MLS sensitivity labels
>>> > on IPv6 packets using a hop-by-hop option.  CALIPSO is very similar to
>>> > its IPv4 cousin CIPSO and much of this series is based on that code.
>>>
>>> What tree do you expect to integrate this?
>>
>> My understanding is that Paul Moore is happy to take them
>> in via the SELinux tree.  However, these patches do touch
>> some core networking code, such as the IPv6 option handling
>> code (in a similar manner to the way CIPSO touched the IPv4
>> option code), so if you have any comments on those aspects
>> that would be good to hear.
>
> No objections on my part.

Okay.

The changes between v3 and v4 were pretty trivial so I've gone ahead
and merged v4 into the SELinux next branch.  Huw, thanks very much for
all of this, I know it was a lot of work.

-- 
paul moore
www.paul-moore.com
