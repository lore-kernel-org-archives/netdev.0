From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug?  TCP shutdown behaviour when deleting local IP addresses
Date: Thu, 18 Oct 2012 09:29:42 +0200
Message-ID: <1350545382.26103.1103.camel@edumazet-glaptop>
References: <507F38D4.102@genband.com>
	 <1350540348.26103.1015.camel@edumazet-glaptop>
	 <507FAAE1.6000903@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35915 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468Ab2JRH3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 03:29:48 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so3958027bkc.19
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2012 00:29:47 -0700 (PDT)
In-Reply-To: <507FAAE1.6000903@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-18 at 01:08 -0600, Chris Friesen wrote:

> 
> While I agree generally, it's a bit unfortunate that we can't (as a 
> quality of implementation thing) give an earlier notice of failure since 
> the kernel knows about both ends of the connection even though the IP 
> address is gone.  On the other hand, I imagine that would mean 
> special-casing things and presumably that would open a whole can of worms.

Really what is the difference between a cable cut and what you are
doing ?

Some frames are lost (Dropped), and sender doesnt 'know' that is
definitive or temporary failure.

If you want faster response, you need to send RST messages, not dropping
frames.

So change your strategy, and add an iptables rule for example ?
