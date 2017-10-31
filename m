From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [PATCH iproute2 1/1] ip netns: use strtol() instead of atoi()
Date: Tue, 31 Oct 2017 14:01:32 -0400
Message-ID: <85efpjfb7n.fsf@mojatatu.com>
References: <1509123327-31751-1-git-send-email-mrv@mojatatu.com>
        <20171031173101.59e0047a@shemminger-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:53175 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751316AbdJaSBe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:01:34 -0400
Received: by mail-io0-f173.google.com with SMTP id f20so630310ioj.9
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:01:34 -0700 (PDT)
In-Reply-To: <20171031173101.59e0047a@shemminger-XPS-13-9360> (Stephen
        Hemminger's message of "Tue, 31 Oct 2017 17:31:01 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> writes:

> On Fri, 27 Oct 2017 12:55:27 -0400
> Roman Mashak <mrv@mojatatu.com> wrote:
>
>> Use strtol-based API to parse and validate integer input; atoi() does not detect
>> errors and may yield undefined behaviour if result can't be represented.
>> 
>> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
>
> Since network namespace is really an unsigned value, shouldn't it be
> using get_unsigned?

Agree, I will resend v2.
