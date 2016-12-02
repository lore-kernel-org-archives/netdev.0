From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next 2/2] net/sched: cls_flower: Support matching on
 ICMP type and code
Date: Fri, 2 Dec 2016 21:33:04 +0100
Message-ID: <20161202203303.GA25934@penelope.horms.nl>
References: <1480701951-3686-1-git-send-email-simon.horman@netronome.com>
 <1480701951-3686-3-git-send-email-simon.horman@netronome.com>
 <20161202183848.GF1883@nanopsycho.orion>
 <20161202191712.GA32484@penelope.horms.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f179.google.com ([209.85.210.179]:35624 "EHLO
        mail-wj0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751948AbcLBUdI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 15:33:08 -0500
Received: by mail-wj0-f179.google.com with SMTP id v7so241366036wjy.2
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 12:33:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161202191712.GA32484@penelope.horms.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

On Fri, Dec 02, 2016 at 08:17:13PM +0100, Simon Horman wrote:
> On Fri, Dec 02, 2016 at 07:38:48PM +0100, Jiri Pirko wrote:
> > Fri, Dec 02, 2016 at 07:05:51PM CET, simon.horman@netronome.com wrote:
> > >Support matching on ICMP type and code.

...

> > This hunk looks like it should be squashed to the previous patch.
> 
> I included it in this patch as it is where these helpers are used
> for the first time. I can shuffle it into the first patch if you prefer;
> I agree it does make sense to put all the dissector changes there.

I moved things around as you suggested and posted v2.
