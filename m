From: Shawn Landden <shawn@churchofgit.com>
Subject: Re: [PATCH] pipe_to_sendpage: Ensure that MSG_MORE is set if we set MSG_SENDPAGE_NOTLAST
Date: Sun, 24 Nov 2013 16:03:21 -0800
Message-ID: <CAJusiZXDaKva-+t-cD5oWYodwt-evTWv-xj+z7j3oJFhBk01aw@mail.gmail.com>
References: <CAJusiZXN4dOxg9S4ZiCziVXfNZ+=yu7a=84vUikV2RhbhYU7QA@mail.gmail.com>
	<1385336527-27304-1-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org
To: Richard Weinberger <richard@nod.at>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1385336527-27304-1-git-send-email-richard@nod.at>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 24, 2013 at 3:42 PM, Richard Weinberger <richard@nod.at> wrote:
> Commit 35f9c09fe (tcp: tcp_sendpages() should call tcp_push() once)
> added an internal flag MSG_SENDPAGE_NOTLAST.
> We have to ensure that MSG_MORE is also set if we set MSG_SENDPAGE_NOTLAST.
> Otherwise users that check against MSG_MORE will not see it.
>
> This fixes sendfile() on AF_ALG.
>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: <stable@vger.kernel.org> # 3.4.x

The offending commit also got backported to the 3.2 stable kernel, so
we need this fix there as well.
---
Shawn Landden
+1 360 389 3001 (SMS preferred)
