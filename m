From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: Set maximum receive packet size on
 veth interfaces
Date: Tue, 09 May 2017 13:48:39 -0400 (EDT)
Message-ID: <20170509.134839.2008658486655854998.davem@davemloft.net>
References: <20170509124439.45674-1-fredrik.markstrom@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, daniel@iogearbox.net, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, ast@kernel.org,
	linux-kernel@vger.kernel.org
To: fredrik.markstrom@gmail.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170509124439.45674-1-fredrik.markstrom@gmail.com>
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

From: Fredrik Markstrom <fredrik.markstrom@gmail.com>
Date: Tue,  9 May 2017 14:44:36 +0200

> Currently veth drops all packets larger then the mtu set on the
> receiving end of the pair. This is inconsistent with most hardware
> ethernet drivers.

False.

In fact, many pieces of ethernet hardware a not physically capable of
sending even VLAN packets that are above the normal base ethernet MTU.

It is therefore untenable to remove this restriction univerally like
this.
