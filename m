From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH v4 00/19] CALIPSO Implementation
Date: Tue, 21 Jun 2016 15:33:39 -0400
Message-ID: <CAHC9VhT53P2+B3SkiWkvpczpVE=MjJ85EkL4A+MKEtbKwpXONw@mail.gmail.com>
References: <1466429819-12707-1-git-send-email-huw@codeweavers.com>
 <20160621.053928.1340819307282355897.davem@davemloft.net> <20160621095548.GA19213@merlot.physics.ox.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Huw Davies <huw@codeweavers.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:35337 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751628AbcFUTdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 15:33:40 -0400
Received: by mail-oi0-f44.google.com with SMTP id r2so382984oih.2
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 12:33:40 -0700 (PDT)
In-Reply-To: <20160621095548.GA19213@merlot.physics.ox.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 21, 2016 at 5:55 AM, Huw Davies <huw@codeweavers.com> wrote:
> On Tue, Jun 21, 2016 at 05:39:28AM -0400, David Miller wrote:
>> From: Huw Davies <huw@codeweavers.com>
>> Date: Mon, 20 Jun 2016 14:36:40 +0100
>>
>> > This patch series implements RFC 5570 - Common Architecture Label IPv6
>> > Security Option (CALIPSO).  Its goal is to set MLS sensitivity labels
>> > on IPv6 packets using a hop-by-hop option.  CALIPSO is very similar to
>> > its IPv4 cousin CIPSO and much of this series is based on that code.
>>
>> What tree do you expect to integrate this?
>
> My understanding is that Paul Moore is happy to take them
> in via the SELinux tree.  However, these patches do touch
> some core networking code, such as the IPv6 option handling
> code (in a similar manner to the way CIPSO touched the IPv4
> option code), so if you have any comments on those aspects
> that would be good to hear.

Huw is correct.  I haven't yet gone through this latest patchset,
although I've reviewed the previous versions and provided feedback;
the v3 revision looked pretty good to me and I'm assuming I won't find
any showstoppers in the v4 revision.

I'm happy to push this upstream via the SELinux tree, but only with an
implicit ACK from DaveM since it does touch of the core stack (in ways
comparable to what we did for CIPSO and IPv4).  If DaveM would prefer
to merge these patches via the netdev tree, that's fine too, I'll take
a closer look later this week and send my ACKs.

DaveM, let me know how you want to proceed with this patchset.

-- 
paul moore
www.paul-moore.com
