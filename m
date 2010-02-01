From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: debug: nt_conntrack and KVM crash
Date: Mon, 1 Feb 2010 12:47:23 +0200
Message-ID: <b6fcc0a1002010247s70b855b6kea66c99c9326b6a@mail.gmail.com>
References: <1264813832.2793.446.camel@tonnant>
	 <1264816634.2793.505.camel@tonnant>
	 <1264816777.2793.510.camel@tonnant>
	 <1264834704.2919.3.camel@edumazet-laptop>
	 <1265016745.7499.144.camel@tonnant>
	 <b6fcc0a1002010136k7e78a998p31a9e7464c2e8d44@mail.gmail.com>
	 <1265020552.7499.147.camel@tonnant>
	 <b6fcc0a1002010244j161f7f0bob46053efc0d65630@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Jon Masters <jonathan@jonmasters.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b6fcc0a1002010244j161f7f0bob46053efc0d65630@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 1, 2010 at 12:44 PM, Alexey Dobriyan <adobriyan@gmail.com> wrote:
> So, insert printk into nf_conntrack_set_hashsize().

Or even printk nf_conntrack_htable_size during bootup and panic/oops.
