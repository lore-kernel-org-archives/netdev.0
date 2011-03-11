From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Thu, 10 Mar 2011 16:57:04 -0800
Message-ID: <AANLkTi=F=za4OaNbiT71oTj+HKZG1sJE=YrrjpUb4AS7@mail.gmail.com>
References: <20110310.153444.115930379.davem@davemloft.net>
 <AANLkTimnHtVS=SFopgyjAAQDW8bXDKDXf+YvEtPdpPsA@mail.gmail.com>
 <20110310.155556.48513201.davem@davemloft.net> <AANLkTik3AyFTNoytebmOOZ=JSFMkt0bw7au-CSncUHJu@mail.gmail.com>
 <AANLkTiktUsR1vXo84H2m_tLZRgDGee+JdvxGZjX7hYMq@mail.gmail.com> <AANLkTikiy+hNgG=BRWKkHEHCdvJnffWP6nhp1XxsEEO+@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dave Airlie <airlied@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikiy+hNgG=BRWKkHEHCdvJnffWP6nhp1XxsEEO+@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 10, 2011 at 4:40 PM, Dave Airlie <airlied@gmail.com> wrote:
>
> I didn't realise we weren't meant to --no-ff, I've been lately using
> --no-ff --log
> so I can keep track of what I merged easier, when someone bases something on my
> tree and I haven't moved it in a while.

Well, the whole "--no-ff --log" is really designed for exactly that.
It's the "I'm the upstream maintainer, and I want that nice merge
summary". And it really is useful for that.

So I don't know about "weren't meant to". It very much is why those
flags exist (I don't personally use "--log", but that's because since
I'm the very top maintainer I've just set the flag in my .git/config
flag that makes _all_ my merges logging merges).

It's just that when I started doing git, the fast-forward merge was
very much a design decision. But I have to admit that I really like my
merge summaries too, and the main reason I have never really
considered using --no-ff is that _my_ tree moves so often that
practically speaking, I never fast-forward. If I get a fast-forward
merge, it almost always means that some submaintainer did something
iffy (like rebase his tree), and that the commits from that
submaintainer haven't been around for very long.

So no, I don't think you've been wrong in using "--no-ff --log". It
does make sense.

I just have my own private hang-ups about why I'm not personally a
huge fan of --no-ff.

But now that I've done it once, maybe I'm hooked. It's like coke to
Charlie Sheen.

                          Linus
