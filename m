From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net: Fix inconsistent teardown and release of private
 netdev state.
Date: Mon, 12 Jun 2017 13:40:48 -0700
Message-ID: <20170612134048.21715cbd@plumbers-lap.home.lan>
References: <20170607.155411.201795978436906426.davem@davemloft.net>
        <20170609102104.34c26568@xeon-e3>
        <20170609.145434.399590645965329804.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:34758 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752712AbdFLUkz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 16:40:55 -0400
Received: by mail-pg0-f42.google.com with SMTP id v18so49844756pgb.1
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 13:40:55 -0700 (PDT)
In-Reply-To: <20170609.145434.399590645965329804.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 09 Jun 2017 14:54:34 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Fri, 9 Jun 2017 10:21:04 -0700
> 
> > Is there anything in Documentation/networking/netdevices.txt about this to
> > avoid any future issues?  
> 
> You asked me about this last time, and I did not forget about it.
> 
> I sincerely lack the time to do a writeup about it, and I felt that
> delaying the fix for another week or two until I find that magical
> non-existing timeframe to write the docs was not beneficial for
> users at all.

I could take a stab at it, but my writing skills are not great.
We don't need to delay for Documentation, in fact it is easier to write after
the cleanup.
