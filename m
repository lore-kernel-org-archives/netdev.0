From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [RFC] string matching ematch
Date: Thu, 27 Jan 2005 21:17:39 +0100
Message-ID: <41F94C63.7010800@eurodev.net>
References: <20050126150714.GL31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, Patrick McHardy <kaber@trash.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050126150714.GL31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Thomas,

Thomas Graf wrote:

>I'd like to discuss the string matching ematch, I don't care about the
>algorithm used but rather whether to make it stateful, match over
>fragments, etc. I attached a simple stateless string matching ematch
>using the Knuth-Morris-Pratt algorithm as a starting point.
>  
>

I've posted something similar after christmas in netfilter-devel[1]. 
It's fragment aware, actually my implementation uses boyer-moore to look 
for matches in the payload, and it uses brute force together with 
Rusty's skb_iter stuff to look for matches on the edges. The worst case 
is not that bad for small patterns. Anyway I'm still looking for 
alternatives solutions. BTW, Harald Welte is also interested in this stuff.

I'll give it more spins these days since I've got some spare time. I'll 
also have a look at your work. I think that we could join efforts and 
push something good, thoughts?

References:

https://lists.netfilter.org/pipermail/netfilter-devel/2005-January/018034.html

--
Pablo
