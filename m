From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net v2] openvswitch: Fix mask generation for nested attributes.
Date: Sat, 12 Sep 2015 17:04:35 -0700
Message-ID: <CALnjE+o2oXMDrJMbtrav_36WEivJ-TC56wOAs8J3N+6VaaGH1A@mail.gmail.com>
References: <1442021908-47034-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:32985 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752441AbbIMAEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Sep 2015 20:04:36 -0400
Received: by iofh134 with SMTP id h134so133325056iof.0
        for <netdev@vger.kernel.org>; Sat, 12 Sep 2015 17:04:35 -0700 (PDT)
In-Reply-To: <1442021908-47034-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 11, 2015 at 6:38 PM, Jesse Gross <jesse@nicira.com> wrote:
> Masks were added to OVS flows in a way that was backwards compatible
> with userspace programs that did not generate masks. As a result, it is
> possible that we may receive flows that do not have a mask and we need
> to synthesize one.
>
> Generating a mask requires iterating over attributes and descending into
> nested attributes. For each level we need to know the size to generate the
> correct mask. We do this with a linked table of attribute types.
>
> Although the logic to handle these nested attributes was there in concept,
> there are a number of bugs in practice. Examples include incomplete links
> between tables, variable length attributes being treated as nested and
> missing sanity checks.
>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Thanks for the fix.
Acked-by: Pravin B Shelar <pshelar@nicira.com>
