From: David Miller <davem@davemloft.net>
Subject: Re: Finding a hidden bound TCP socket
Date: Wed, 23 Nov 2011 16:01:43 -0500 (EST)
Message-ID: <20111123.160143.58902472755124590.davem@davemloft.net>
References: <CALmbKGV0g2nfNAghF5dGrt=TCyrms6RznOL8jSkg+gkgyfekLg@mail.gmail.com>
	<CAFLxGvynabpEcX2RwiLxatjOEzizj95jAVY6E4D9ymDpn8s9UA@mail.gmail.com>
	<CALmbKGVUuZs+wigpkr0WPfn2pYP=tQh5-MsYWeRxbug=HskVQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richard.weinberger@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: gdfuego@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALmbKGVUuZs+wigpkr0WPfn2pYP=tQh5-MsYWeRxbug=HskVQQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "G. D. Fuego" <gdfuego@gmail.com>
Date: Wed, 23 Nov 2011 15:27:33 -0500

> Any comments?  The behavior seems broken.  At the very least its very
> inconsistent with other Unixes.

Until the socket has a full final tuple it is bound to, there is no
reason to list it.

No UNIX lists a socket which is partially bound and hasn't either
performed a listen() or a connect().

Nobody has any comments because nobody thinks it's worth worrying about.
