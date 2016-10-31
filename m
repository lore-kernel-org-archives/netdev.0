From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add an ioctl to get a socket network
 namespace
Date: Mon, 31 Oct 2016 10:58:08 -0400 (EDT)
Message-ID: <20161031.105808.1717498783593722519.davem@davemloft.net>
References: <1477358953-3547-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, containers@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-api@vger.kernel.org
To: avagin@openvz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477358953-3547-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrei Vagin <avagin@openvz.org>
Date: Mon, 24 Oct 2016 18:29:13 -0700

> From: Andrey Vagin <avagin@openvz.org>
> 
> Each socket operates in a network namespace where it has been created,
> so if we want to dump and restore a socket, we have to know its network
> namespace.
> 
> We have a socket_diag to get information about sockets, it doesn't
> report sockets which are not bound or connected.
> 
> This patch introduces a new socket ioctl, which is called SIOCGSKNS
> and used to get a file descriptor for a socket network namespace.
> 
> A task must have CAP_NET_ADMIN in a target network namespace to
> use this ioctl.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> Signed-off-by: Andrei Vagin <avagin@openvz.org>

Applied.
