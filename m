From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 03/16] net: Basic network namespace infrastructure.
Date: Sun, 09 Sep 2007 04:18:22 -0600
Message-ID: <m1642kta4x.fsf@ebiederm.dsl.xmission.com>
References: <m1r6l8x3vq.fsf@ebiederm.dsl.xmission.com>
	<m1myvwx3sf.fsf@ebiederm.dsl.xmission.com>
	<m1ir6kx3mn.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ejh8x3ih.fsf_-_@ebiederm.dsl.xmission.com>
	<46E3B281.4030105@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46E3B281.4030105-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org> (Eric Dumazet's message of "Sun,
	09 Sep 2007 10:44:49 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org> writes:
>
> Nice work Eric !

Thanks.

> "struct net" is not a very descriptive name imho, why dont stick "ns" or
> "namespace" somewhere ?

My fingers rebelled, and struct net seems to be sufficiently descriptive.
However that is a cosmetic detail and if there is a general consensus
that renaming it to be struct netns or whatever would be a more
readable/maintainable name I can change it.

> Do we really need yet another "struct kmem_cache *net_cachep;" ?
> The object is so small that the standard caches should be OK (kzalloc())

The practical issue at this point in the cycle is visibility.  With a
kmem cache it is easy to spot ref counting leaks or other problems
if they happen.  Without it debugging is much more difficult.  While I
am touched with your faith in my ability to write perfect patches I
think it makes a lot of sense to keep the cache at least until
sometime after the network namespace code is merged and people
generally have confidence in the implementation.

Eric
