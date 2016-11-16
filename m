From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: allow to enable the repair mode for
 non-listening sockets
Date: Tue, 15 Nov 2016 22:29:27 -0500 (EST)
Message-ID: <20161115.222927.1939756937813091251.davem@davemloft.net>
References: <1479176114-12658-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, criu@openvz.org
To: avagin@openvz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479176114-12658-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrei Vagin <avagin@openvz.org>
Date: Mon, 14 Nov 2016 18:15:14 -0800

> The repair mode is used to get and restore sequence numbers and
> data from queues. It used to checkpoint/restore connections.
> 
> Currently the repair mode can be enabled for sockets in the established
> and closed states, but for other states we have to dump the same socket
> properties, so lets allow to enable repair mode for these sockets.
> 
> The repair mode reveals nothing more for sockets in other states.
> 
> Signed-off-by: Andrei Vagin <avagin@openvz.org>

Applied.
