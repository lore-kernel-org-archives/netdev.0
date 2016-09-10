From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dwc_eth_qos: do not register semi-initialized
 device
Date: Fri, 09 Sep 2016 19:20:38 -0700 (PDT)
Message-ID: <20160909.192038.1381124057816689516.davem@davemloft.net>
References: <1473333861-1319-1-git-send-email-larper@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        andrianov@ispras.ru, larper@axis.com
To: lars.persson@axis.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473333861-1319-1-git-send-email-larper@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lars Persson <lars.persson@axis.com>
Date: Thu,  8 Sep 2016 13:24:21 +0200

> We move register_netdev() to the end of dwceqos_probe() to close any
> races where the netdev callbacks are called before the initialization
> has finished.
> 
> Reported-by: Pavel Andrianov <andrianov@ispras.ru>
> Signed-off-by: Lars Persson <larper@axis.com>

Applied.
