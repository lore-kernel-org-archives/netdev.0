From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch net-next 3/5] ipv6: consider net.ipv6.conf.all sysctls
 when making decisions
Date: Tue, 10 Jun 2014 10:13:34 -0700
Message-ID: <20140610101334.565bc484@nehalam.linuxnetplumber.net>
References: <1402417153-2551-1-git-send-email-milos.vyletel@gmail.com>
	<1402417153-2551-4-git-send-email-milos.vyletel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, amwang@redhat.com, netdev@vger.kernel.org,
	Oliver Neukum <oliver@neukum.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florent Fourcot <florent.fourcot@enst-bretagne.fr>,
	Eric Dumazet <edumazet@google.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	linux-usb@vger.kernel.org (open list:USB CDC ETHERNET...),
	linux-kernel@vger.kernel.org (open list)
To: Milos Vyletel <milos.vyletel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402417153-2551-4-git-send-email-milos.vyletel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Jun 2014 12:19:11 -0400
Milos Vyletel <milos.vyletel@gmail.com> wrote:

> As it is right now net.ipv6.conf.all.* are mostly ignored and instead
> we're only making decisions based on interface specific settings. These
> settings are coppied from net.ipv6.conf.default and changing either all
> or default settings have no effect.

Although this is the right idea conceptually, it risks creating unhappy
users because it changes the semantics of the API. This will probably break
somebody's configuration.
