From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Notify userspace about bridge learning MAC on
	new port
Date: Mon, 17 Mar 2014 21:50:05 -0400 (EDT)
Message-ID: <20140317.215005.1881170250001094391.davem@davemloft.net>
References: <1394630096-14239-1-git-send-email-michael-dev@fami-braun.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: michael-dev@fami-braun.de
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1394630096-14239-1-git-send-email-michael-dev@fami-braun.de>
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

From: Michael Braun <michael-dev@fami-braun.de>
Date: Wed, 12 Mar 2014 14:14:56 +0100

> Currently, the userspace is informed about the port the MAC is learned on a
> bridge and about the bridge removing the MAC from its forwarding table, but not
> when the MAC is learned on a different port.
> This is inconsistent and makes it difficult for applications to keep track
> of all MACs learned by a bridge on a subset of its ports.
> 
> Signed-off-by: Michael Braun <michael-dev@fami-braun.de>
> Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Please use a proper subsystem prefix in your Subject lines, for
example:

"Subject: [PATCH] bridge: Notify userspace about learning MAC on new port"

Would have been more appropriate here.

Stephen, can you review the substance of this patch please?
