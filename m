From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2 1/1] ip netns: use strtol() instead of
 atoi()
Date: Wed, 1 Nov 2017 22:06:41 +0100
Message-ID: <20171101220641.2b710a94@shemminger-XPS-13-9360>
References: <1509474259-9988-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:47538 "EHLO
        mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755327AbdKAVHH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 17:07:07 -0400
Received: by mail-lf0-f41.google.com with SMTP id k40so4018475lfi.4
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 14:07:07 -0700 (PDT)
In-Reply-To: <1509474259-9988-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Oct 2017 14:24:19 -0400
Roman Mashak <mrv@mojatatu.com> wrote:

> Use strtol-based API to parse and validate integer input; atoi() does
> not detect errors and may yield undefined behaviour if result can't be
> represented.
> 
> v2: use get_unsigned() since network namespace is really an unsigned value.
> 
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>

Applied. Thanks Roman
