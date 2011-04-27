From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] Applying inappropriate ioctl operation on socket should
 return ENOTTY
Date: Wed, 27 Apr 2011 10:47:38 +0100
Message-ID: <20110427104738.2bdbe228@lxorguk.ukuu.org.uk>
References: <1303882625-28115-1-git-send-email-lifongsun@gmail.com>
	<1303883910.2699.53.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Lifeng Sun <lifongsun@gmail.com>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1303883910.2699.53.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> EINVAL is ok too : Request or argp is not valid.

It confuses portable code in some situations
 
> I would say, its not a bug as you claim. 

POSIX and SuS tend to disagree

> Its really too late to make such change and risk regressions.

We've been quietly doing it for hundreds of cases including the entire
tty driver. Almost nobody (you included) has actually noticed and in
doing so we fixed various porting funnies without any reported
regressions.

Networking may be a more tricky one (not that tty wasn't a large one we
fixed) but most of the other driver ones are clearly sensible.

Alan
