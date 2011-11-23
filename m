From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: RAW netfilter - "advanced netfilter setting" or not?
Date: Wed, 23 Nov 2011 23:32:23 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1111232325500.27025@frira.zrqbmnf.qr>
References: <CA+55aFxtSgLppJQ8EbQEovdXsCNxQ1gT31FyP2cpyuvoBLajZw@mail.gmail.com> <alpine.LNX.2.01.1111232217220.27025@frira.zrqbmnf.qr> <CA+55aFyQGf4sFNOVsv4krddn3gxQ=roqVHpC98-Ynx8iBqpRaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFyQGf4sFNOVsv4krddn3gxQ=roqVHpC98-Ynx8iBqpRaQ@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2011-11-23 23:02, Linus Torvalds wrote:
>On Wed, Nov 23, 2011 at 1:27 PM, Jan Engelhardt <jengelh@medozas.de> wrote:
>>
>> In my opinion, NETFILTER_ADVANCED should be changed to only control
>> the visibility of all suboptions, i.e. I suggest that "default m if
>> NETFILTER_ADVANCED=n" be done for all non-deprecated modules.
>> (Similar to how CONFIG_EXPERT works.)
>
>No thank you. That makes the whole option pointless. [...]
>The whole point of NETFILTER_ADVANCED is for people like me who
>actually want a fairly *minimal* kernel config, and probably one that
>has no modules.

Right, but how would you decide what will be enabled/disabled by
default? It seems unlikely you will be adding a patch (like Dave's)
everytime a default distro installation throws certain errors once
you run your own kernel configs.
