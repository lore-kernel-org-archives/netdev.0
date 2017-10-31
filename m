From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/1] ip netns: use strtol() instead of atoi()
Date: Tue, 31 Oct 2017 17:31:01 +0100
Message-ID: <20171031173101.59e0047a@shemminger-XPS-13-9360>
References: <1509123327-31751-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:45339 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753566AbdJaQb0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 12:31:26 -0400
Received: by mail-lf0-f43.google.com with SMTP id n69so19754045lfn.2
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 09:31:25 -0700 (PDT)
In-Reply-To: <1509123327-31751-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Oct 2017 12:55:27 -0400
Roman Mashak <mrv@mojatatu.com> wrote:

> Use strtol-based API to parse and validate integer input; atoi() does not detect
> errors and may yield undefined behaviour if result can't be represented.
> 
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>

Since network namespace is really an unsigned value, shouldn't it be
using get_unsigned?
