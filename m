From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH v3] netfilter: Xtables: idletimer target implementation
Date: Wed, 9 Jun 2010 23:05:28 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1006092304270.16916@obet.zrqbmnf.qr>
References: <1275592445-15555-1-git-send-email-luciano.coelho@nokia.com>  <4C0F9B17.10504@trash.net> <1276096275.31892.117.camel@chilepepper>  <alpine.LSU.2.01.1006091716170.30265@obet.zrqbmnf.qr>  <1276105707.11199.12.camel@powerslave>
 <1276108939.11199.23.camel@powerslave>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ext Patrick McHardy <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Timo Teras <timo.teras@iki.fi>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1276108939.11199.23.camel@powerslave>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 2010-06-09 20:42, Luciano Coelho wrote:
>
>> I'll move the sysfs file creation to outside that function so I can keep
>> the lock until after the timer is added to the list.  Thanks for
>> clarifying!
>
>Hmmm... after struggling with this for a while, I think it's not really
>possible to simply create the sysfs file outside of the lock, because if
>the sysfs creation fails, we will again risk a race condition.

Well if sysfs_add can return an error code when a file already
exists (instead of adding it again), it's much easier. Try checking.
