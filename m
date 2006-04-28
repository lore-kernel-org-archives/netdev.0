From: Alexey Toptygin <alexeyt@freeshell.org>
Subject: Re: [PATCH] fix unlikely usage in tcp_transmit_skb()
Date: Fri, 28 Apr 2006 23:45:01 +0000 (UTC)
Message-ID: <Pine.NEB.4.62.0604282324180.3253@norge.freeshell.org>
References: <Pine.LNX.4.64.0604260947040.2907@localhost.localdomain>
 <20060428.152551.50641016.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: hzhong@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.freeshell.ORG ([192.94.73.18]:31711 "EHLO sdf.lonestar.org")
	by vger.kernel.org with ESMTP id S965004AbWD1Xpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 19:45:43 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060428.152551.50641016.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Apr 2006, David S. Miller wrote:

> From: Hua Zhong <hzhong@gmail.com>
> Date: Wed, 26 Apr 2006 09:50:28 -0700 (PDT)
>
>> [I hope this time it's OK - I'm sending from pine/Linux]
>
> It adds an extra space in the diff lines which corrupts
> the patch.

You can work around this by enabling quell-flowed-text - then pine will 
never mangle patches. Currently (pine4.64), if you're disabling flowed 
text on a per-message basis with ^V before sending, patches containing 
trailing whitespace will get mangled. Pine labels the message as not 
flowed, but does the mangling anyway :-/

Tooting my own horn here, but I submitted a pine patch this week which 
fixes the issue. Hopefully, the next pine release will behave correctly. 
You'll still have to remember to hit ^V before sending mail containing 
patches, and you should always use ^R to include patch files, since 
newlines in the input are treated magically. Or, you can enable 
quell-flowed-text, and pretend the whole flowed text feature never 
happened. I'll shut up about pine now :-)

 			Alexey
