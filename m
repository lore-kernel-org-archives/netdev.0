From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next] switchdev: fix BUG when port driver doesn't
 support set attr op
Date: Wed, 10 Jun 2015 15:51:28 -0600
Message-ID: <5578B160.1070501@gmail.com>
References: <1433969762-22406-1-git-send-email-sfeldma@gmail.com> <5578AB3C.5020206@gmail.com> <CAE4R7bD2RLa9D1_JnGr4RUMYHWMa-kQab=1ihN3YMkJgLqFViw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Brenden Blanco <bblanco@plumgrid.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:37770 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015AbbFJVva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 17:51:30 -0400
Received: by igbsb11 with SMTP id sb11so42593302igb.0
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 14:51:29 -0700 (PDT)
In-Reply-To: <CAE4R7bD2RLa9D1_JnGr4RUMYHWMa-kQab=1ihN3YMkJgLqFViw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/10/15 3:47 PM, Scott Feldman wrote:
>> Should that be WARN_ON instead of BUG_ON?
>
> I think I had it as WARN when we were working on the initial patches,
> but we changed it to BUG_ON because we should only get an error here
> if the driver screwed something up between PREPARE phase and COMMIT
> phase, so it should be considered a driver bug which needs fixing.
>

Linus rants from time to time about the prolific use of BUG_ON. e.g.,
     https://lkml.org/lkml/2015/4/28/528

'BUG_ON() is for things where our internal data structures are so 
corrupted that we don't know what to do, and there's no way to continue. 
Not for "I want to sprinkle these things around and this should not 
happen".'

David
