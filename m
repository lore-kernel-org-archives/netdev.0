From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pipe_to_sendpage: Ensure that MSG_MORE is set if we set
 MSG_SENDPAGE_NOTLAST
Date: Mon, 25 Nov 2013 16:02:00 -0800
Message-ID: <1385424120.10637.136.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAJusiZXN4dOxg9S4ZiCziVXfNZ+=yu7a=84vUikV2RhbhYU7QA@mail.gmail.com>
	 <1385336527-27304-1-git-send-email-richard@nod.at>
	 <1385342706.10637.125.camel@edumazet-glaptop2.roam.corp.google.com>
	 <47783210.a9ocpbYofP@sandpuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	viro@zeniv.linux.org.uk, shawnlandden@gmail.com,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org
To: Richard Weinberger <richard@nod.at>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <47783210.a9ocpbYofP@sandpuppy>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-11-25 at 08:42 +0100, Richard Weinberger wrote:

> In the commit message of your patch you wrote "For all sendpage() providers, 
> its a transparent change.". Why does AF_ALG need special handling?
> If users have to care about MSG_SENDPAGE_NOTLAST it is no longer really an 
> internal flag.

MSG_SENDPAGE_NOTLAST is an internal (kernel) flag.

Fact that I missed some MSG_MORE 'users' in the kernel was an oversight.

I am not saying your patch is not needed, I am only saying it reverts
a useful TCP optimization, and we can do better, dont we ?
