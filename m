From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] f_flower: don't set TCA_FLOWER_KEY_ETH_TYPE
 for "protocol all"
Date: Fri, 20 Jan 2017 09:34:45 -0800
Message-ID: <20170120093445.69306d0b@xeon-e3>
References: <20170119215159.GA32126@nvt-d.home.kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcrl@kvack.org
To: Benjamin LaHaise <benjamin.lahaise@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:35602 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751303AbdATRll (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 12:41:41 -0500
Received: by mail-pg0-f42.google.com with SMTP id 194so25175539pgd.2
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 09:41:41 -0800 (PST)
In-Reply-To: <20170119215159.GA32126@nvt-d.home.kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Jan 2017 16:51:59 -0500
Benjamin LaHaise <benjamin.lahaise@netronome.com> wrote:

> When using the tc filter flower, rules marked with "protocol all" do not
> actually match all packets.  This is due to a bug in f_flower.c that passes
> in ETH_P_ALL in the TCA_FLOWER_KEY_ETH_TYPE attribute when adding a rule.
> Fix this by omitting TCA_FLOWER_KEY_ETH_TYPE if the protocol is set to
> ETH_P_ALL.
>     
> Signed-off-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>
> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

This looks good, but does not apply cleanly to either master or net-next branch
of current repository. Please rebase and resubmit.

It would be helpful to to use Fixes: tag for something which was broken by
a single previous commit.
