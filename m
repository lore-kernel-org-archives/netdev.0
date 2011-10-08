From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC] net: remove erroneous sk null assignment in timestamping
Date: Sat, 8 Oct 2011 09:59:26 +0200
Message-ID: <20111008075924.GB2284@netboy.at.omicron.at>
References: <1318007501.3988.20.camel@jlt3.sipsolutions.net>
 <20111007.133356.489094996618032061.davem@davemloft.net>
 <1318009222.3988.28.camel@jlt3.sipsolutions.net>
 <1318012932.3974.7.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34720 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412Ab1JHH72 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2011 03:59:28 -0400
Received: by bkbzt4 with SMTP id zt4so5827712bkb.19
        for <netdev@vger.kernel.org>; Sat, 08 Oct 2011 00:59:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1318012932.3974.7.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 07, 2011 at 08:42:12PM +0200, Johannes Berg wrote:
> Maybe that's how you can trigger it: have one thread turn on and off
> timestamping all the time, and another thread send frames all the time,
> then eventually you'll probably run into the kfree_skb() case there. If
> you ever manage to run into that case, it'll crash either when freeing
> this skb or when freeing the original.

Thats one weird app, but I get the point, and thanks for your
attention to my code.

Richard
 
