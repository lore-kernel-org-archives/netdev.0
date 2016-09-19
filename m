From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 0/4] net-next: dsa: set_addr should be optional
Date: Mon, 19 Sep 2016 12:41:29 -0700
Message-ID: <217121e8-6d8a-93c2-fb62-e9288424960e@gmail.com>
References: <1474291683-44167-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: John Crispin <john@phrozen.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474291683-44167-1-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/19/2016 06:27 AM, John Crispin wrote:
> The Marvell driver is the only one that actually sets the switches HW
> address. All other drivers have an empty stub. fix this by making the
> callback optional.
> 
> John Crispin (4):
>   net-next: dsa: fix duplicate invocation of set_addr()
>   net-next: dsa: make the set_addr() operation optional
>   net-next: dsa: b53: remove empty set_addr() stub
>   net-next: dsa: qca8k: remove empty set_addr() stub

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
