From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH] vxlan: Wrong type passed to %pIS
Date: Sat, 07 Feb 2015 13:38:10 +0100
Message-ID: <87siehnbgt.fsf@rasmusvillemoes.dk>
References: <1423275451-3663-1-git-send-email-linux@rasmusvillemoes.dk>
	<1423280138.2933.3.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dan Carpenter <dan.carpenter@oracle.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423280138.2933.3.camel@perches.com> (Joe Perches's message of
	"Fri, 06 Feb 2015 19:35:38 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 07 2015, Joe Perches <joe@perches.com> wrote:

> On Sat, 2015-02-07 at 03:17 +0100, Rasmus Villemoes wrote:
>> src_ip is a pointer to a union vxlan_addr, one member of which is a
>> struct sockaddr. Passing a pointer to src_ip is wrong; one should pass
>> the value of src_ip itself. Since %pIS formally expects something of
>> type struct sockaddr*, let's pass a pointer to the appropriate union
>> member, though this of course doesn't change the generated code.
>
> Hello Rasmus
>
> Are you finding these mismatches by hand or
> are you using some tool?

I've extended smatch to do format checking (mostly for the %p
extensions; gcc already does all the other stuff just fine). I'll try
and see if I can get it on github sometime in the coming week.

Rasmus
