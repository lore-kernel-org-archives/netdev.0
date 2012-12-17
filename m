From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v3] netfilter: nf_conntrack_sip: Handle Cisco 7941/7945
 IP phones
Date: Mon, 17 Dec 2012 10:55:08 +0100
Message-ID: <20121217095508.GB17148@1984>
References: <f0955e6c2110044fa058d0f3ecf945ca@localhost>
 <1290412334.2756.141.camel@edumazet-laptop>
 <1355703441.18919.6.camel@shinybook.infradead.org>
 <20121217004457.GA12234@1984>
 <CAJiQ=7BBquMQmQWp3=aD_s3-rSYr4Y+gke0GJKCkJV-mq5buug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Woodhouse <dwmw2@infradead.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Kevin Cernekee <cernekee@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAJiQ=7BBquMQmQWp3=aD_s3-rSYr4Y+gke0GJKCkJV-mq5buug@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 16, 2012 at 11:26:31PM -0800, Kevin Cernekee wrote:
> On Sun, Dec 16, 2012 at 4:44 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> >> What happened to this? OpenWRT is still carrying it, and it broke in
> >> 3.7. Here's a completely untested update...
> >
> > I requested Kevin to resend a new version based on the current kernel
> > tree while spinning on old pending patches since I have no access to
> > that hardware, but no luck.
> >
> > So I'll review this and, since OpenWRT is carrying, I guess we can get
> > this into net-next merge window.
> 
> Sorry, been putting it off since the OpenWRT version has worked flawlessly...
> 
> I just reassembled my test rig and I'll get you a working patch this week.
> 
> Is it OK to use
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git as the
> baseline?

That's fine in this case because no recent changes went into that
code, but better if you use the netfilter next tree:

git://1984.lsi.us.es/nf-next

Thanks Kevin.
