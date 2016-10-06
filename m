From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [GIT] Networking
Date: Thu, 6 Oct 2016 13:51:52 +1100
Message-ID: <20161006135152.3fd229cb@canb.auug.org.au>
References: <20161005.014437.1946431553783736769.davem@davemloft.net>
        <20161006092947.25ae781c@canb.auug.org.au>
        <CA+55aFzbHD95PMUk4JQfAVkDDRcwzZ6vfvMR60tZnQNSwkDE6A@mail.gmail.com>
        <20161006115235.1a89c0da@canb.auug.org.au>
        <CA+55aFz0jv3xAQTwrspM3HkXQLVv_H4QuHf9a0Fq2Zm+=_sDtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        NetFilter <netfilter-devel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Liping Zhang <liping.zhang@spreadtrum.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFz0jv3xAQTwrspM3HkXQLVv_H4QuHf9a0Fq2Zm+=_sDtQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Linus,

On Wed, 5 Oct 2016 19:14:21 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:
>
> On Wed, Oct 5, 2016 at 5:52 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> >
> > Except that commit effectively moved that function from
> > net/netfilter/nf_tables_netdev.c to
> > include/net/netfilter/nf_tables_ipv4.h while commit c73c24849011
> > ("netfilter: nf_tables_netdev: remove redundant ip_hdr assignment")
> > removed the assignment in the original file (and has been in your tree
> > since v4.8-rc7) and that is where I originally actually got a conflict.  
> 
> Oh, interesting. Why didn't I get the conflict there then?
> 
> I'm guessing (but too lazy to actually look up the history), that
> David ended up doing that merge and that ends up being why I never saw
> a conflict.

Yeah, commit b50afd203a5e ("Merge
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net") actually
merges v4.8 into the net-next tree.

-- 
Cheers,
Stephen Rothwell
