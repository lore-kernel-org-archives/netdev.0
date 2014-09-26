From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: mmotm 2014-09-25-16-28 uploaded (nf_nat_masquerade_ipv4.c)
Date: Fri, 26 Sep 2014 19:45:17 +0200
Message-ID: <20140926174517.GA11463@salvia>
References: <5424a53b.o+nym6SX0Tg7EdW6%akpm@linux-foundation.org>
 <54259A5C.2060102@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54259A5C.2060102@infradead.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Randy,

On Fri, Sep 26, 2014 at 09:54:52AM -0700, Randy Dunlap wrote:
> On 09/25/14 16:28, akpm@linux-foundation.org wrote:
> > The mm-of-the-moment snapshot 2014-09-25-16-28 has been uploaded to
> > 
> >    http://www.ozlabs.org/~akpm/mmotm/
> > 
> > mmotm-readme.txt says
> > 
> > README for mm-of-the-moment:
> > 
> > http://www.ozlabs.org/~akpm/mmotm/
> > 
> > This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> > more than once a week.
> 
> ../net/ipv4/netfilter/nf_nat_masquerade_ipv4.c: In function 'nf_nat_masquerade_ipv4':
> ../net/ipv4/netfilter/nf_nat_masquerade_ipv4.c:59:5: error: 'struct nf_conn_nat' has no member named 'masq_index'
>   nat->masq_index = out->ifindex;
>      ^
> ../net/ipv4/netfilter/nf_nat_masquerade_ipv4.c: In function 'device_cmp':
> ../net/ipv4/netfilter/nf_nat_masquerade_ipv4.c:83:12: error: 'const struct nf_conn_nat' has no member named 'masq_index'
>   return nat->masq_index == (int)(long)ifindex;
>             ^
> ../net/ipv4/netfilter/nf_nat_masquerade_ipv4.c:84:1: warning: control reaches end of non-void function [-Wreturn-type]

I'll pass this patch in the upcoming nf-next batch:

http://git.kernel.org/cgit/linux/kernel/git/pablo/nf-next.git/commit/?id=67981fefb20e717cea55b42f9081a833fa46b3be

Thanks.
