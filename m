From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: use skb_get_hash() instead of a
 homegrown implementation
Date: Mon, 25 Jan 2016 10:53:23 -0800 (PST)
Message-ID: <20160125.105323.453007330881616541.davem@davemloft.net>
References: <1453734041-20394-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: gnomes@lxorguk.ukuu.org.uk, eric.dumazet@gmail.com, netdev@vger.kernel.org,
 haiyangz@microsoft.com, linux-kernel@vger.kernel.org, tom@herbertland.com,
 devel@linuxdriverproject.org
To: vkuznets@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1453734041-20394-1-git-send-email-vkuznets@redhat.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Vitaly Kuznetsov <vkuznets@redhat.com>
Date: Mon, 25 Jan 2016 16:00:41 +0100

> Recent changes to 'struct flow_keys' (e.g commit d34af823ff40 ("net: Add
> VLAN ID to flow_keys")) introduced a performance regression in netvsc
> driver. Is problem is, however, not the above mentioned commit but the
> fact that netvsc_set_hash() function did some assumptions on the struct
> flow_keys data layout and this is wrong.
> 
> Get rid of netvsc_set_hash() by switching to skb_get_hash(). This change
> will also imply switching to Jenkins hash from the currently used Toeplitz
> but it seems there is no good excuse for Toeplitz to stay.
> 
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>

Applied.
