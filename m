From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Sun, 12 Aug 2012 13:54:22 +0300
Message-ID: <20120812105421.GI1421@redhat.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
 <1343840975-3252-10-git-send-email-ogerlitz@mellanox.com>
 <87boitz044.fsf@xmission.com>
 <20120805185031.GA18640@redhat.com>
 <CAJZOPZKtdvxTGvrxj+T896mEexb=yN9s1cCuqUmhhzCOvUPEnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net,
	roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, Erez Shitrit <erezsh@mellanox.co.il>,
	Doug Ledford <dledford@redhat.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9749 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750828Ab2HLKzh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2012 06:55:37 -0400
Content-Disposition: inline
In-Reply-To: <CAJZOPZKtdvxTGvrxj+T896mEexb=yN9s1cCuqUmhhzCOvUPEnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 08, 2012 at 08:23:15AM +0300, Or Gerlitz wrote:
> > So far the things that make sense. Here are some that don't, to me:
> 
> > - Is a pdf presentation all you have in terms of documentation?
> >   We are talking communication protocols here - I would expect a
> >   proper spec, and some effort to standardize, otherwise where's the
> >   guarantee it won't change in an incompatible way?
> 
> To be precise, the solution uses 100% IPoIB wire-protocol, so we don't
> see a need
> for any spec change / standardization effort.

Thinking about it some more, the solution is not really 100% local:
- ARP packets used at migration are visible on the network
- QPN/LID in MAC are guest visible, and could be exported on the network
