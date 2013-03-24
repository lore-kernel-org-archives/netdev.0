From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: fix crash when set mac address of br
	interface
Date: Sun, 24 Mar 2013 17:28:04 -0400 (EDT)
Message-ID: <20130324.172804.152818486141712380.davem@davemloft.net>
References: <1364041670-3408-1-git-send-email-honkiko@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, zhiguo.hong@emc.com,
	herbert@gondor.hengli.com.au
To: honkiko@gmail.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1364041670-3408-1-git-send-email-honkiko@gmail.com>
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

From: Hong Zhiguo <honkiko@gmail.com>
Date: Sat, 23 Mar 2013 20:27:50 +0800

> When I tried to set mac address of a bridge interface to a mac
> address which already learned on this bridge, I got system hang.
> 
> The cause is straight forward: function br_fdb_change_mac_address
> calls fdb_insert with NULL source nbp. Then an fdb lookup is
> performed. If an fdb entry is found and it's local, it's OK. But
> if it's not local, source is dereferenced for printk without NULL
> check.
> 
> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>

Applied.
