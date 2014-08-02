From: Nikolay Aleksandrov <nikolay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 1/3] lib: Resizable, Scalable,
 Concurrent Hash Table
Date: Sat, 02 Aug 2014 12:32:41 +0200
Message-ID: <53DCBE49.5040507@redhat.com>
References: <cover.1406971567.git.tgraf@suug.ch>
 <f7740ef7d22a334a775348caee916f1ddb3c584d.1406971567.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
 netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
 walpole-sKt6ljEC1JY3uPMLIKxrzw@public.gmane.org
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <f7740ef7d22a334a775348caee916f1ddb3c584d.1406971567.git.tgraf-G/eBtMaohhA@public.gmane.org>
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
> Generic implementation of a resizable, scalable, concurrent hash table
> based on [0]. The implementation supports both, fixed size keys specified
> via an offset and length, or arbitrary keys via own hash and compare
> functions.
> 
> Lookups are lockless and protected as RCU read side critical sections.
> Automatic growing/shrinking based on user configurable watermarks is
> available while allowing concurrent lookups to take place.
> 
> Objects to be hashed must include a struct rhash_head. The reason for not
> using the existing struct hlist_head is that the expansion and shrinking
> will have two buckets point to a single entry which would lead in obscure
> reverse chaining behaviour.
> 
> Code includes a boot selftest if CONFIG_TEST_RHASHTABLE is defined.
> 
> [0] https://www.usenix.org/legacy/event/atc11/tech/final_files/Triplett.pdf
> 
> Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
> ---
>  include/linux/rhashtable.h | 213 ++++++++++++
>  lib/Kconfig.debug          |   8 +
>  lib/Makefile               |   2 +-
>  lib/rhashtable.c           | 797 +++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 1019 insertions(+), 1 deletion(-)
>  create mode 100644 include/linux/rhashtable.h
>  create mode 100644 lib/rhashtable.c
> 

Reviewed-by: Nikolay Aleksandrov <nikolay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
