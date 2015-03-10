From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: use sock_efree instead of own destructor
Date: Tue, 10 Mar 2015 15:55:32 +0100
Message-ID: <54FF05E4.6060002@hartkopp.net>
References: <1425959300-27132-1-git-send-email-fw@strlen.de>	 <54FE8BB0.9050508@hartkopp.net>	 <1425990143.8261.28.camel@edumazet-glaptop2.roam.corp.google.com>	 <54FEF355.305@hartkopp.net> <1425998185.8261.51.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	mkl@pengutronix.de,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1425998185.8261.51.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/10/2015 03:36 PM, Eric Dumazet wrote:
> On Tue, 2015-03-10 at 14:36 +0100, Oliver Hartkopp wrote:

>> Maybe Alexander can send a patch which adds a comment, as I don't know if I
>> would find the best words for it.
> 
> Please do not top post on netdev.

? I did not.

> If you cannot find best words for it, maybe a comment would not be
> useful : Very often, best comments are added by people that had problems
> to understand the code ;)

Yes that's why I asked the original author to do so - he hopefully understood
his code :-)

> 
> I do not trust comments, I prefer using "git grep" or tools like that to
> check call sites.
> 
> In this particular case this becomes clear, while being concise.
> 
> # git grep -n sock_efree

A good hint! Will use this first in the future.

Thanks,
Oliver

