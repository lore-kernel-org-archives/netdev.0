From: linux@horizon.com
Subject: Re: [PATCH] OpenBSD Networking-related randomization port
Date: 31 Jan 2005 23:27:35 -0000
Message-ID: <20050131232735.11236.qmail@science.horizon.com>
References: <20050131201141.GA4879@elte.hu>
Cc: arjan@infradead.org, bunk@stusta.de, chrisw@osdl.org, davem@redhat.com,
        hlein@progressive-comp.com, linux-kernel@vger.kernel.org,
        linux@horizon.com, netdev@oss.sgi.com, shemminger@osdl.org,
        Valdis.Kletnieks@vt.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: lorenzo@gnu.org, mingo@elte.hu
In-Reply-To: <20050131201141.GA4879@elte.hu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> could you please also react to this feedback:
>
>   http://marc.theaimsgroup.com/?l=linux-kernel&m=110698371131630&w=2
> 
> to quote a couple of key points from that very detailed security
> analysis:
> 
> " I'm not sure how the OpenBSD code is better in any way.  (Notice that
>   it uses the same "half_md4_transform" as Linux; you just added another
>   copy.) Is there a design note on how the design was chosen? "

Just note that, in addition to the security aspects, there are also a
whole set of multiprocessor issues.  OpenBSD added SMP support in June
2004, and it looks like this code dates back to before that.  It might
be worth looking at what OpenBSD does now.

Note that I have NOT looked at the patch other than the TCP ISN
generation.  However, given the condition of the ISN code, I am inclined
to take a "guilty until proven innocent" view of the rest of it.
Don't merge it until someone has really grokked it, not just kibitzed
about code style issues.

(The homebrew 15-bit block cipher in this code does show how much the
world needs a small block cipher for some of these applications.)
