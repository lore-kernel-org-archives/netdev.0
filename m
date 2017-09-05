From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] tun: reserve extra headroom only when XDP
 is set
Date: Tue, 05 Sep 2017 14:26:51 -0700 (PDT)
Message-ID: <20170905.142651.2109065087625525085.davem@davemloft.net>
References: <1504496169-31190-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        mst@redhat.com, kubakici@wp.pl
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504496169-31190-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Mon,  4 Sep 2017 11:36:08 +0800

> We reserve headroom unconditionally which could cause unnecessary
> stress on socket memory accounting because of increased trusesize. Fix
> this by only reserve extra headroom when XDP is set.
> 
> Cc: Jakub Kicinski <kubakici@wp.pl>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied.
