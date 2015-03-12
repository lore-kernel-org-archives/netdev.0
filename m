From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: iproute2: ip netns: Do not delete netns if there any process use
 it
Date: Thu, 12 Mar 2015 10:31:06 +0200
Message-ID: <20150312083106.GA1016@angus-think.wlc.globallogic.com>
References: <20150311074020.GA26477@angus-think.wlc.globallogic.com>
 <CAHA+R7Pwfjg4642i1FMG1mKJN58K+nYhqvN_NnrbQ+uiPXibGQ@mail.gmail.com>
 <20150311165011.GA917@angus-think.lan>
 <CAHA+R7PsYQLVXse5Yjk6K9V==Yw2WUM=rYGi1KPRf+bwZAwDxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:37899 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057AbbCLImp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 04:42:45 -0400
Received: by lbiz12 with SMTP id z12so14361066lbi.5
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 01:42:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAHA+R7PsYQLVXse5Yjk6K9V==Yw2WUM=rYGi1KPRf+bwZAwDxQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2015 at 10:07:50AM -0700, Cong Wang wrote:
> 
> It is your responsibility to track the processes you put into the netns.
Yes.

I just was thinking that there is no reason to delete netns file
when there are the processes that uses this netns, so some kind of safe
validation would be helpful.

But if no one think that it can be the right think then may be at least
adding some explanation about this in ip-netns man page would be helpful.

Thanks,
