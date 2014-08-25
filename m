From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/3] net: propagate sock pointer through
 netfilter hooks
Date: Mon, 25 Aug 2014 21:29:26 +0200
Message-ID: <20140825192926.GC1871@nanopsycho.lan>
References: <1408127576-11518-1-git-send-email-jiri@resnulli.us>
 <20140821.173339.1409243624518012670.davem@davemloft.net>
 <20140825140510.GB1871@nanopsycho.lan>
 <20140825.115103.943827907985622489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, stephen@networkplumber.org,
	cwang@twopensource.com, pshelar@nicira.com,
	nicolas.dichtel@6wind.com, therbert@google.com,
	dborkman@redhat.com, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:50390 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754493AbaHYT33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 15:29:29 -0400
Received: by mail-wg0-f44.google.com with SMTP id m15so13331133wgh.3
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 12:29:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140825.115103.943827907985622489.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Aug 25, 2014 at 08:51:03PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Mon, 25 Aug 2014 16:05:10 +0200
>
>> Dave, I see that the patchset is in state "Changes requested". I do not
>> think I understand what is needed to be done at this point. Would you
>> please tell me? Thanks.
>
>I said there is too much churn so I want an alternative approach
>considered.
>
>Also want you to fix the ipv6 fragmentation error too.


Hmm. When skb->x adding is no-go and propagating sk through nf hooks is
no go, I really do not see the way to fix this... I might be missing
something though...
