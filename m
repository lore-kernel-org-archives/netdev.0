From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 2.6.12-rc1-bk1] multipath: early use of inlined function
Date: Tue, 22 Mar 2005 20:08:02 -0800
Message-ID: <20050322200802.014d7f57.davem@davemloft.net>
References: <20050321213409.GA28998@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050321213409.GA28998@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 21 Mar 2005 22:34:09 +0100
Francois Romieu <romieu@fr.zoreil.com> wrote:

> $ grep -n compare_keys net/ipv4/route.c
> 151:static inline int compare_keys(struct flowi *fl1, struct flowi *fl2);
>                                                                        ^^^
> 541:                compare_keys(&(*rthp)->fl, &expentry->fl)) {
> 861:static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
> 890:                compare_keys(&rth->fl, &rt->fl)) {
> 892:            if (compare_keys(&rth->fl, &rt->fl)) {
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

Applied, thanks Francois.
