From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: use net->count to check whether a netns is alive
 or not
Date: Mon, 13 Mar 2017 16:03:16 -0700 (PDT)
Message-ID: <20170313.160316.2050029482820012246.davem@davemloft.net>
References: <20170313043618.16183-1-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-4
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, grawity@gmail.com, stable@vger.kernel.org
To: avagin@openvz.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170313043618.16183-1-avagin@openvz.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrei Vagin <avagin@openvz.org>
Date: Sun, 12 Mar 2017 21:36:18 -0700

> The previous idea was to check whether a net namespace is in
> net_exit_list or not. It doesn't work, because net->exit_list is used in
> __register_pernet_operations and __unregister_pernet_operations where
> all namespaces are added to a temporary list to make cleanup in a error
> case, so list_empty(&net->exit_list) always returns false.
> 
> Reported-by: Mantas Mikulìnas <grawity@gmail.com>
> Fixes: 002d8a1a6c11 ("net: skip genenerating uevents for network namespaces that are exiting")
> Signed-off-by: Andrei Vagin <avagin@openvz.org>

Applied and queued up for -stable, thanks.
