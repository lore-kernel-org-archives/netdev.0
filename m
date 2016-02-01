From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] nftables: use list_for_each_entry_safe_reverse to
 traversal commit_list in nf_tables_abort
Date: Mon, 1 Feb 2016 12:08:23 +0100
Message-ID: <20160201110823.GA8361@salvia>
References: <15bcb964221e1a9498e901417d020609cd5aac65.1449485287.git.lucien.xin@gmail.com>
 <20151209140330.GA1695@salvia>
 <CADvbK_dmqu4aFhQa2FVu=_RAVrSZ6qSixfGN9EM2dZ20CeQqUA@mail.gmail.com>
 <20151213214709.GA1827@salvia>
 <CADvbK_dRmfuJj2ZzueUhSgP4za8A2J1nn9eJvq1fncWsbGGuqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, davem <davem@davemloft.net>,
	fw@strlen.de
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CADvbK_dRmfuJj2ZzueUhSgP4za8A2J1nn9eJvq1fncWsbGGuqA@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 01, 2016 at 06:47:33PM +0800, Xin Long wrote:
> >
> > No need to resend.
> >
> > Yes, we need this reverse iteration there to handle the 'delete table'
> > command in the batch. This problem happens since we have
> > nft_flush_table().
> >
> > Other callsites are artificially restriction deletion of inactive
> > objects but that should be removed as we already discuss on the
> > mailing list.
> >
> > So I'm applying this, thanks.
> 
> Hi Pablo, has this one been applied ?

commit a907e36d54e0ff836e55e04531be201bf6b4d8c8
Author: Xin Long <lucien.xin@gmail.com>
Date:   Mon Dec 7 18:48:07 2015 +0800

    netfilter: nf_tables: use reverse traversal commit_list in nf_tables_abort

