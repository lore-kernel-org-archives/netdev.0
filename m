From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] tg3: Expand 4g_overflow_test workaround to skb
 fragments of any size.
Date: Fri, 27 Dec 2013 12:52:12 -0500 (EST)
Message-ID: <20131227.125212.271765824553403823.davem@davemloft.net>
References: <1387503851-14253-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org, mchan@broadcom.com
To: nsujir@broadcom.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1387503851-14253-1-git-send-email-nsujir@broadcom.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nithin Nayak Sujir <nsujir@broadcom.com>
Date: Thu, 19 Dec 2013 17:44:11 -0800

> The current driver assumes that an skb fragment can only be upto jumbo
> size. Presumably this was a fast-path optimization. This assumption is
> no longer true as fragments can be upto 32k.
> 
> v2: Remove unnecessary parantheses per Eric Dumazet.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thank you.
