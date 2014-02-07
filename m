From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tg3: Fix deadlock in tg3_change_mtu()
Date: Thu, 06 Feb 2014 16:54:48 -0800 (PST)
Message-ID: <20140206.165448.1676259324527494823.davem@davemloft.net>
References: <1391724785-13562-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.vrabel@citrix.com,
	stable@vger.kernel.org, mchan@broadcom.com
To: nsujir@broadcom.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1391724785-13562-1-git-send-email-nsujir@broadcom.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Networking patches should never be CC:'d to -stable.  And you should
never add the:

Cc: <stable@vger.kernel.org>

tag to networking commit messages.

Instead, after the "---" delimiter, you should kindly request that
I queue up that patch for stable, and why.  I handle networking
stable submissions on my own.
