From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH v2] unix: properly account for FDs passed over unix sockets
Date: Tue, 2 Feb 2016 21:49:55 +0100
Message-ID: <20160202204955.GD25828@1wt.eu>
References: <201601100657.u0A6vk1B025554@mail.home.local> <CANq1E4T0sqTTD4RsWXTUrFvsKvEsKsUiPbskWd=wAEVu83_Srg@mail.gmail.com> <56B0F574.5080105@stressinduktion.org> <CA+55aFw2AwsWbvwp6f8H+eExt_CMfh7VA3od6hto_M0hg9z3Tg@mail.gmail.com> <56B11278.8000805@stressinduktion.org> <CA+55aFz0CXGexEBmb8JU0+w7sFf3VfE3TpRzdj3aTiDxg2zDpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Herrmann <dh.herrmann@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	???????? ?????????????????? <socketpair@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Simon McVittie <simon.mcvittie@collabora.co.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFz0CXGexEBmb8JU0+w7sFf3VfE3TpRzdj3aTiDxg2zDpg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 02, 2016 at 12:44:54PM -0800, Linus Torvalds wrote:
> On Tue, Feb 2, 2016 at 12:32 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > But "struct pid *" in unix_skb_parms should be enough to get us to
> > corresponding "struct cred *" so we can decrement the correct counter during
> > skb destruction.
> 
> Umm. I think the "struct cred" may change in between, can't it?

You mean for example in case of setuid() or something like this ?

willy
