From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] bridge: export multicast database
 via netlink
Date: Fri, 07 Dec 2012 14:33:18 -0500 (EST)
Message-ID: <20121207.143318.2265851271191305391.davem@davemloft.net>
References: <1354874688-24564-1-git-send-email-amwang@redhat.com>
	<20121207103629.GB2996@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, herbert@gondor.hengli.com.au,
	brouer@redhat.com, shemminger@vyatta.com
To: tgraf@suug.ch
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20121207103629.GB2996@casper.infradead.org>
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

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 7 Dec 2012 10:36:29 +0000

> On 12/07/12 at 06:04pm, Cong Wang wrote:
>> From: Cong Wang <amwang@redhat.com>
>> 
>> V5: fix two bugs pointed out by Thomas
>>     remove seq check for now, mark it as TODO
>> 
>> V4: remove some useless #include
>>     some coding style fix
>> 
>> V3: drop debugging printk's
>>     update selinux perm table as well
>> 
>> V2: drop patch 1/2, export ifindex directly
>>     Redesign netlink attributes
>>     Improve netlink seq check
>>     Handle IPv6 addr as well
>> 
>> This patch exports bridge multicast database via netlink
>> message type RTM_GETMDB. Similar to fdb, but currently bridge-specific.
>> We may need to support modify multicast database too (RTM_{ADD,DEL}MDB).
>> 
>> (Thanks to Thomas for patient reviews)
>> 
>> Cc: Herbert Xu <herbert@gondor.apana.org.au>
>> Cc: Stephen Hemminger <shemminger@vyatta.com>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: Thomas Graf <tgraf@suug.ch>
>> Cc: Jesper Dangaard Brouer <brouer@redhat.com>
>> Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> Acked-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks.
