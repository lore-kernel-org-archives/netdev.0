From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP: snd_cwnd is nul, please report this bug.
Date: Tue, 02 Apr 2013 22:12:47 -0700
Message-ID: <1364965967.5113.195.camel@edumazet-glaptop>
References: <20130403035428.GA31709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:34266 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752378Ab3DCFMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 01:12:50 -0400
Received: by mail-pb0-f52.google.com with SMTP id mc8so637745pbc.25
        for <netdev@vger.kernel.org>; Tue, 02 Apr 2013 22:12:50 -0700 (PDT)
In-Reply-To: <20130403035428.GA31709@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-02 at 23:54 -0400, Dave Jones wrote:
> Just had this warning on 3.9-rc5
> 
> Not sure what else to report.  Nothing really odd going on,
> just some ssh traffic and firefox over wifi (iwlwifi)
> 
> anything else I can provide ?

Thanks for the report.

I guess we'll need to resurrect a patch I did to track the (buggy)
setting to 0.
