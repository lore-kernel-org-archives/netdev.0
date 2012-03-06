From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: fix "entering disabled state" logging
Date: Tue, 06 Mar 2012 14:33:23 -0500 (EST)
Message-ID: <20120306.143323.1591818099708591757.davem@davemloft.net>
References: <20120306142219.31783.30201.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: paulius.zaleckas@gmail.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20120306142219.31783.30201.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Date: Tue, 06 Mar 2012 16:22:19 +0200

> Now we have:
> eth0: link down
> br0: port 1(eth0) entering forwarding state
> 
> State should be logged *after* it was changed, not before.
> 
> Reported-by: Zilvinas Valinskas <zilvinas@wilibox.com>
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@gmail.com>

This is intentional, this was a discussion about this.

"Entering" means "about to" therefore we say it before it happens.
