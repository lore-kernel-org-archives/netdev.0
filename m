From: Dmitry Popov <dp@highloadlab.com>
Subject: Re: [PATCH] tcp: md5 signature check scaling
Date: Wed, 27 Oct 2010 17:18:42 +0400
Message-ID: <AANLkTinbfZX3Lmj9omq6a+QNErjfRFBQGi0Kr9osud5O@mail.gmail.com>
References: <AANLkTi=U1smX6XXDMyBTicyqbUU5V-t56jmH7qtX2XW5@mail.gmail.com>
	<1288184405.2709.108.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	William.Allen.Simpson@gmail.com,
	Andreas Petlund <apetlund@simula.no>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Gilad Ben-Yossef <gilad@codefidence.com>,
	Yony Amit <yony@comsleep.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Artyom Gavrichenkov <ag@highloadlab.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1288184405.2709.108.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 27, 2010 at 5:00 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> This is a huge patch :(
>
> Reading changelog, I dont understand what you did, and why you did this.
>
> You want to avoid taking the socket lock ? But we need to take it anyway
> to process packets.

Hi.

Well, I removed the dependence on socket lock from md5* functions. Yes
we need to take it to process packets, but sockets in LISTEN state may
process them without socket lock(patch coming soon). And I find md5
signature check scaling interesting even without LISTEN state scaling
patch.

Regards,
Dmitry.
