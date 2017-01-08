From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH net-next V2 0/3] net/sched: act_pedit: Use offset
 relative to conventional network headers
Date: Sun, 8 Jan 2017 10:46:24 +0200
Message-ID: <20170108084624.GA26775@office.localdomain>
References: <20170105095454.32644-1-amir@vadai.me>
 <20170106.205109.917848391545129035.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com, ogerlitz@mellanox.com,
        hadarh@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f194.google.com ([209.85.210.194]:33322 "EHLO
        mail-wj0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751197AbdAHIq2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 03:46:28 -0500
Received: by mail-wj0-f194.google.com with SMTP id kp2so82488109wjc.0
        for <netdev@vger.kernel.org>; Sun, 08 Jan 2017 00:46:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170106.205109.917848391545129035.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 06, 2017 at 08:51:09PM -0500, David Miller wrote:
> From: Amir Vadai <amir@vadai.me>
> Date: Thu,  5 Jan 2017 11:54:51 +0200
> 
> > Enhancing the UAPI to allow for specifying that would allow the same
> > flows to be set into both SW and HW.
> 
> This is actually not backward compatible.
> 
> When pedit rules are dumped, older tools will not know about the
> type field and therefore will completely misinterpret the rule.
> 
> You must extend this the proper way, which is to add a new attribute
> or something along those lines.  The presense of a new attribute
> is an explicit communication to older tools that somethng they
> might not support and understand is going on.

Sorry, I missed this scenario. Going back to the drawing board.
