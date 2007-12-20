From: "Parag Warudkar" <parag.warudkar@gmail.com>
Subject: Re: [PATCH 2/2] net: neighbor timer power saving
Date: Thu, 20 Dec 2007 13:16:21 -0500
Message-ID: <82e4877d0712201016qe920d68lf9f7eb8c8f117265@mail.gmail.com>
References: <Pine.LNX.4.64.0712181956180.3616@mini.warudkars.net>
	 <20071218174120.4b0ef6dd@shemminger-laptop>
	 <20071218181845.2f1b539a@shemminger-laptop>
	 <4768C6FF.2090909@cosmosbay.com> <20071220091005.310ab2f8@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <dada1@cosmosbay.com>,
	"David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.235]:50063 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S938250AbXLTSQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 13:16:23 -0500
Received: by nz-out-0506.google.com with SMTP id s18so1859946nze.1
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2007 10:16:22 -0800 (PST)
In-Reply-To: <20071220091005.310ab2f8@deepthought>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 20, 2007 12:10 PM, Stephen Hemminger
<shemminger@linux-foundation.org> wrote:

> Thinking about it more, this looks like a case for just using round_jiffies().
> The GC timer needs to run to clean up under DoS attack, and deferring it probably
> isn't a good idea.

But what are the chances that a DoSed machine will be idling which
will prevent the GC timer to run? I would think there would be lot of
other activities going on (including non-deferrable timers running)
that will avoid this situation?

Parag
