From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] appletalk: Fix socket referencing in skb
Date: Tue, 08 Jul 2014 19:40:21 -0700 (PDT)
Message-ID: <20140708.194021.617273242591768642.davem@davemloft.net>
References: <1404764570-24120-1-git-send-email-andrey.krieger.utkin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, acme@ghostprotocols.net,
	eric.dumazet@gmail.com
To: andrey.krieger.utkin@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404764570-24120-1-git-send-email-andrey.krieger.utkin@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrey Utkin <andrey.krieger.utkin@gmail.com>
Date: Mon,  7 Jul 2014 23:22:50 +0300

> Setting just skb->sk without taking its reference and setting a
> destructor is invalid. However, in the places where this was done, skb
> is used in a way not requiring skb->sk setting. So dropping the setting
> of skb->sk.
> Thanks to Eric Dumazet <eric.dumazet@gmail.com> for correct solution.
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=79441
> Reported-by: Ed Martin <edman007@edman007.com>
> Signed-off-by: Andrey Utkin <andrey.krieger.utkin@gmail.com>

Applied and queued up for -stable.
