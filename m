From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 3/8] bridge: Add functionality to sync
 static fdb entries to hw
Date: Thu, 15 May 2014 00:47:43 +0400
Message-ID: <5373D66F.4080801@cogentembedded.com>
References: <1400080168-16625-1-git-send-email-vyasevic@redhat.com>
	<1400080168-16625-4-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, jhs@mojatatu.com, mst@redhat.com
To: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1400080168-16625-4-git-send-email-vyasevic@redhat.com>
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

On 05/14/2014 07:09 PM, Vlad Yasevich wrote:

> Add code that allows static fdb entires to be synced to the
> hw list for a specified port.  This will be used later to
> program ports that can function in non-promiscuous mode.

> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>   net/bridge/br_fdb.c     | 56 +++++++++++++++++++++++++++++++++++++++++++++++++
>   net/bridge/br_private.h |  2 ++
>   2 files changed, 58 insertions(+)

> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index 9203d5a..9759b61 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -874,3 +874,59 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
>   out:
>   	return err;
>   }
> +
> +int br_fdb_sync_static(struct net_bridge *br, struct net_bridge_port *p)
> +{
> +	struct net_bridge_fdb_entry *fdb, *tmp = NULL;

    Again, initializer doesn't seem to be needed.

> +	int i;
> +	int err = 0;

    This one as well.

[...]

WBR, Sergei
