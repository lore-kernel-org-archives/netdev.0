From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: Re: igmp problem
Date: Mon, 5 Sep 2005 18:22:46 +0200
Message-ID: <9a874849050905092279e8e860@mail.gmail.com>
References: <20050905155640.GA18216@codeblau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751019AbVIEQWs@vger.kernel.org>
To: "felix-linuxkernel@fefe.de" <felix-linuxkernel@fefe.de>
In-Reply-To: <20050905155640.GA18216@codeblau.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/5/05, felix-linuxkernel@fefe.de <felix-linuxkernel@fefe.de> wrote:
> Hi!
> 
> I wrote a few multicast tools, which use these multicast groups:
> 
>   225.109.99.112
>   ff02::6d63:7030
>   224.110.99.112
>   ff02::6e63:7030
> 
> I have a Cisco in the middle, and both boxes are in different VLANs.
> The Cisco is sending out igmp queries.  The kernel never answers, even
> after subscribing to these multicast groups.
> 
> The kernel version is 2.4.26.  What could be the problem here?
> 
> I found no netfilter rules, and the kernel has multicast support (at
> least several igmp related sysctls exist).
> 

I'm unfortunately not able to help you with your specific problem, but
a few words of advice: you really ought to start by reproducing the
problem with a recent kernel - like 2.4.31 or 2.6.13.
2.4.26 is really ancient and noone really cares about it any more.

You should probably also talk to the netdev people (CC'ed).

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
