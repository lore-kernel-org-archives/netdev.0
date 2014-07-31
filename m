From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 0/2 net-next] Lockless netlink_lookup() with
 new concurrent hash table
Date: Wed, 30 Jul 2014 19:08:24 -0700 (PDT)
Message-ID: <20140730.190824.1834967880150777985.davem@davemloft.net>
References: <cover.1406633945.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
 walpole-sKt6ljEC1JY3uPMLIKxrzw@public.gmane.org
To: tgraf-G/eBtMaohhA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <cover.1406633945.git.tgraf-G/eBtMaohhA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Date: Tue, 29 Jul 2014 13:41:31 +0200

> Netlink sockets are maintained in a hash table to allow efficient lookup
> via the port ID for unicast messages. However, lookups currently require
> a read lock to be taken. This series adds a new generic, resizable,
> scalable, concurrent hash table based on the paper referenced in the first
> patch. It then makes use of the new data type to implement lockless
> netlink_lookup().
> 
> Against net-next since the initial user of the new hash table is in net/
> 
> Thomas Graf (2):
>   lib: Resizable, Scalable, Concurrent Hash Table
>   netlink: Convert netlink_lookup() to use RCU protected hash table

This series looks great, please post an updated series once you have
addressed the current feedback.

Thanks!
