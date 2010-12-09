From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] netfilter: don't need to initialize instance_table
Date: Thu, 9 Dec 2010 22:27:24 +0800
Message-ID: <AANLkTin6u9ZkSNAoxR7az5yBW-WM0RebPcCrOMOYgFrP@mail.gmail.com>
References: <1291889421-10794-1-git-send-email-xiaosuo@gmail.com> <alpine.LNX.2.01.1012091501270.21049@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1012091501270.21049@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 9, 2010 at 10:03 PM, Jan Engelhardt <jengelh@medozas.de> wrote:
>
> This is here for correctness and documentation. If the hlist
> implementation changed, one would have a hard time figuring out the
> callsites which then need to add the initialization back.
>

I am quite sure there are other users rely on this assumption. So who
wants to change the macro INIT_HLIST_HEAD() has to review all the
code. It is a huge task, but can't be avoided.

For now, calling INIT_HLIST_HEAD() has no benefit, but wastes CPU
cycles and increases the image size.

Thanks.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
