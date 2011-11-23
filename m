From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: RAW netfilter - "advanced netfilter setting" or not?
Date: Wed, 23 Nov 2011 14:02:18 -0800
Message-ID: <CA+55aFyQGf4sFNOVsv4krddn3gxQ=roqVHpC98-Ynx8iBqpRaQ@mail.gmail.com>
References: <CA+55aFxtSgLppJQ8EbQEovdXsCNxQ1gT31FyP2cpyuvoBLajZw@mail.gmail.com>
 <alpine.LNX.2.01.1111232217220.27025@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1111232217220.27025@frira.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 23, 2011 at 1:27 PM, Jan Engelhardt <jengelh@medozas.de> wrote:
>
> In my opinion, NETFILTER_ADVANCED should be changed to only control
> the visibility of all suboptions, i.e. I suggest that "default m if
> NETFILTER_ADVANCED=n" be done for all non-deprecated modules.
> (Similar to how CONFIG_EXPERT works.)

No thank you. That makes the whole option pointless.

If you want all the modules, just hold down the 'm' key, and be done
with it. There's no skill needed, or need for NETFILTER_ADVANCED.

The whole point of NETFILTER_ADVANCED is for people like me who
actually want a fairly *minimal* kernel config, and probably one that
has no modules.

Modules are evil. They are a security issue, and they encourage a
"distro kernel" approach that takes forever to compile. Just say no.
Build a lean and mean kernel that actually has what you need, and
nothing more. And don't spend stupid time compiling modules you won't
need.

I wish we had a better way of doing a sane localized kernel. "make
localyesconfig" certainly isn't it, even if it tries. But options like
NETFILTER_ADVANCED are at least meant to lessen the pain, and not have
to wade through options that no sane person will know whether they
would ever need.

                      Linus
