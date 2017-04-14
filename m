From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/1 v3] drivers: net: rmnet: Initial
 implementation
Date: Fri, 14 Apr 2017 14:59:36 -0700
Message-ID: <20170414145936.40962060@xeon-e3>
References: <1492146329-4304-1-git-send-email-subashab@codeaurora.org>
        <1492146329-4304-2-git-send-email-subashab@codeaurora.org>
        <20170414090752.GA1992@nanopsycho>
        <4549f41894889b5c11411dfb429e5f36@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, fengguang.wu@intel.com, dcbw@redhat.com
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:34584 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751962AbdDNV7i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 17:59:38 -0400
Received: by mail-pg0-f49.google.com with SMTP id 21so48031831pgg.1
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 14:59:38 -0700 (PDT)
In-Reply-To: <4549f41894889b5c11411dfb429e5f36@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Apr 2017 15:57:22 -0600
Subash Abhinov Kasiviswanathan <subashab@codeaurora.org> wrote:

> >> +				rmnet_kfree_skb
> >> +				(skb,
> >> +				 RMNET_STATS_SKBFREE_INGRESS_NOT_EXPECT_MAPD);  
> > 
> > very odd formatting. Please fix.
> >   
> Checkpatch complains if it is over 80 chars in a line, so I had to do 
> this.
> I'll change to a single line.

Either ignore checkpatch, it is only a dumb script; or better yet refactor
the code so it isn't indented so much.
