From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 18/24] sctp: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 23:51:21 +0200
Message-ID: <1314654681.2563.10.camel@edumazet-laptop>
References: <cover.1314650069.git.joe@perches.com>
	 <21b4d996c8861373ac77d427914ec7882fe0c83e.1314650069.git.joe@perches.com>
	 <1314654209.2563.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1314654209.2563.7.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 29 ao=C3=BBt 2011 =C3=A0 23:43 +0200, Eric Dumazet a =C3=A9cri=
t :

> Furthermore, a failed vmalloc() is not guaranteed to emit an OOM
> message, is it ?

It currently displays a message without context :

vmap allocation for size XXXXXX failed: use vmalloc=3D<size> to increas=
e
size.

So we dont know which part of the kernel asked this allocation.

Please dont remove existing error messages after failed vmalloc() calls=
=2E
