From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net 0/2] bridge: Fix forwarding of 8021AD
	frames
Date: Mon, 31 Mar 2014 16:04:54 -0400 (EDT)
Message-ID: <20140331.160454.719171330899746914.davem@davemloft.net>
References: <1395955950-17630-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org
To: vyasevic@redhat.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1395955950-17630-1-git-send-email-vyasevic@redhat.com>
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

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Thu, 27 Mar 2014 17:32:28 -0400

> Bridge has its own way to deterine if the packet is forwardable and it doesn't
> support 8021ad tags correctly.  Instead just allow bridge to use an
> existing is_skb_forwardable() function.
> 
> v2: Fix missing hunk in patch 2/2 to make it build.
> 
> v3: Fix indent for is_skb_forwardable

Applied to net-next, if you really want this to be queued up for -stable
let me know.
