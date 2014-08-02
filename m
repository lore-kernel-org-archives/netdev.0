From: Nikolay Aleksandrov <nikolay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 3/3] nftables: Convert nft_hash to
 use generic rhashtable
Date: Sat, 02 Aug 2014 12:56:15 +0200
Message-ID: <53DCC3CF.4000003@redhat.com>
References: <cover.1406971567.git.tgraf@suug.ch>
 <583cb5fc8f1bc2f47d338dfba06f514e7b89a548.1406971567.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
 netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
 walpole-sKt6ljEC1JY3uPMLIKxrzw@public.gmane.org
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <583cb5fc8f1bc2f47d338dfba06f514e7b89a548.1406971567.git.tgraf-G/eBtMaohhA@public.gmane.org>
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

On 08/02/2014 11:47 AM, Thomas Graf wrote:
> The sizing of the hash table and the practice of requiring a lookup
> to retrieve the pprev to be stored in the element cookie before the
> deletion of an entry is left intact.
> 
> Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
> Acked-by: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
> ---
>  net/netfilter/nft_hash.c | 291 +++++++++--------------------------------------
>  1 file changed, 55 insertions(+), 236 deletions(-)
> 

Reviewed-by: Nikolay Aleksandrov <nikolay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
