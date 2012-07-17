From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-next: make sock diag per-namespace (v2)
Date: Mon, 16 Jul 2012 22:23:48 -0700 (PDT)
Message-ID: <20120716.222348.382977548581101928.davem@davemloft.net>
References: <1342448929-1809316-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, xemul@parallels.com, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: avagin@openvz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1342448929-1809316-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Vagin <avagin@openvz.org>
Date: Mon, 16 Jul 2012 18:28:49 +0400

> Before this patch sock_diag works for init_net only and dumps
> information about sockets from all namespaces.
> 
> This patch expands sock_diag for all name-spaces.
> It creates a netlink kernel socket for each netns and filters
> data during dumping.
> 
> v2: filter accoding with netns in all places
>     remove an unused variable.
> 
> Signed-off-by: Andrew Vagin <avagin@openvz.org>

Applied, thanks.
