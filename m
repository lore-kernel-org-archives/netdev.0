From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][XFRM] Optimize policy dumping
Date: Mon, 04 Dec 2006 09:11:09 -0500
Message-ID: <1165241469.3664.81.camel@localhost>
References: <1165158707.3517.92.camel@localhost>
	 <45741386.5070002@trash.net> <1165238776.3664.40.camel@localhost>
	 <45742825.8040004@trash.net>  <45742964.9000905@trash.net>
	 <1165240725.3664.72.camel@localhost>  <45742B6D.7010509@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:10710 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S936854AbWLDOLP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 09:11:15 -0500
Received: by wx-out-0506.google.com with SMTP id h27so3803513wxd
        for <netdev@vger.kernel.org>; Mon, 04 Dec 2006 06:11:12 -0800 (PST)
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <45742B6D.7010509@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-04-12 at 15:06 +0100, Patrick McHardy wrote:

> Both ways are fine I guess. But the counting has almost no
> overhead with the patch I sent, so I'm not sure if its worth
> adding a callback (which still needs to get the last policy/SA
> as argument, so that part won't get any nicer).
> 
> BTW, I'm not sure whether there are further requirements than
> those you quoted, but according to that text, using 1 for
> all but the last message would be fine as well :)
> 

The only arguement for the callback is it will lead to eventually
having some semi-reliable dump for pfkey. But i think that is a separate
issue to be tackled later.
I am actually scratching my head a little as to what happens when the
pfkey socket recv is full.

cheers,
jamal

