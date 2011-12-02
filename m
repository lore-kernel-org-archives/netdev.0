From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: RAW netfilter - "advanced netfilter setting" or not?
Date: Thu, 1 Dec 2011 19:12:48 -0800
Message-ID: <CA+55aFxwNbQd-SkFoeS2s18u0ZDto8DdZehJRouDQG-4XW-J_A@mail.gmail.com>
References: <CA+55aFzvZowH1_bA66VZ5Aw0wF3KzdGSqiNZLw46J3u4gpKnxA@mail.gmail.com>
 <20111123.160719.540568233963799514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: richard.weinberger@gmail.com, pablo@netfilter.org,
	netdev@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20111123.160719.540568233963799514.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 23, 2011 at 1:07 PM, David Miller <davem@davemloft.net> wrote:
>>
>> So we'd need to unhide both raw and notrack, methinks.
>
> I just tossed the following into my tree:

I found a new one: Fedora 16 needs NF_CONNTRACK_NETBIOS_NS (and thus
NF_CONNTRACK_BROADCAST) for firewalld to work correctly - otherwise it
fails when you try to find network printers.

Yeah, it used to be enough to just use a regular firewall setting that
let IPP through, but that was before firewalld "knew" that you need to
also open up the samba port and netbios.

Oh well.

So can you remove the "depends on NETFILTER_ADVANCED" from
NF_CONNTRACK_NETBIOS_NS too?

Or should I just do it?

                        Linus
