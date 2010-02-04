From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] netfilter: per netns nf_conntrack_cachep
Date: Thu, 4 Feb 2010 14:27:16 +0200
Message-ID: <b6fcc0a1002040427n221da433n755350b4a41bbf9b@mail.gmail.com>
References: <1265108690.2861.118.camel@tonnant>
	 <1265130426.2861.158.camel@tonnant>
	 <b6fcc0a1002020958u17315624u4d54d06a413be6bb@mail.gmail.com>
	 <1265134598.2861.191.camel@tonnant> <4B6870AF.6060109@trash.net>
	 <4B6967BC.600@trash.net> <1265222289.2861.290.camel@tonnant>
	 <20100203190948.GA5182@x200> <1265226227.2861.302.camel@tonnant>
	 <4B6ABCB8.4080904@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jon Masters <jonathan@jonmasters.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B6ABCB8.4080904@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 4, 2010 at 2:25 PM, Patrick McHardy <kaber@trash.net> wrote:
> Jon Masters wrote:
>> On Wed, 2010-02-03 at 21:09 +0200, Alexey Dobriyan wrote:
>>> On Wed, Feb 03, 2010 at 01:38:09PM -0500, Jon Masters wrote:
>>>> *). Per namespace cacheing allocation (the cachep bits). We know it's
>>>> still possible for weirdness to happen in the SLAB cache here.
>>> Tiny race, needs reproducer.
>>
>> Maybe. I think it's worth fixing anyway.
>
> Absolutely, I'll also apply Eric's patch with the %p fix for the
> slab name.

This would show kernel pointers in userspace ;-)
So, net->id is required.
