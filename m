From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 iproute2] f_flower: don't set TCA_FLOWER_KEY_ETH_TYPE
 for "protocol all"
Date: Sun, 29 Jan 2017 20:24:54 -0800
Message-ID: <20170129202454.46c4c661@xeon-e3>
References: <20170120190738.GA17163@nvt-d.home.kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
        bcrl@kvack.org
To: Benjamin LaHaise <benjamin.lahaise@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:34140 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdA3EZC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 23:25:02 -0500
Received: by mail-pg0-f42.google.com with SMTP id 14so97626249pgg.1
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 20:25:02 -0800 (PST)
In-Reply-To: <20170120190738.GA17163@nvt-d.home.kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Jan 2017 14:07:38 -0500
Benjamin LaHaise <benjamin.lahaise@netronome.com> wrote:

> v2 - update to address changes in 00697ca19ae3e1118f2af82c3b41ac4335fe918b.
> 
> When using the tc flower filter, rules marked with "protocol all" do not
> actually match all packets.  This is due to a bug in f_flower.c that passes
> in ETH_P_ALL in the TCA_FLOWER_KEY_ETH_TYPE attribute when adding a rule.
> Fix this by omitting TCA_FLOWER_KEY_ETH_TYPE if the protocol is set to
> ETH_P_ALL.
>     
> Fixes: 488b41d020fb ("tc: flower no need to specify the ethertype")
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>
> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

Applied, thanks.
