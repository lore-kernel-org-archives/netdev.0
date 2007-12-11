From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: net-2.6.25 being rebased...
Date: Tue, 11 Dec 2007 19:09:11 -0200
Message-ID: <20071211210911.GJ24046@ghostprotocols.net>
References: <20071211.092638.148402625.davem@davemloft.net> <20071211.115619.199600421.davem@davemloft.net> <1197407100.4911.150.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49667 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751131AbXLKVJS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 16:09:18 -0500
Content-Disposition: inline
In-Reply-To: <1197407100.4911.150.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Dec 11, 2007 at 01:04:59PM -0800, Joe Perches escreveu:
> On Tue, 2007-12-11 at 11:56 -0800, David Miller wrote:
> > The rebase of net-2.6.25 is complete
> 
> I have an earlier unmodified git repository of net-2.6.25.
> Does anyone know the appropriate git commands to resync
> to the rebased content?
> 
> $ git branch
> * master
> $ git-pull
> [...]
> Automatic merge failed; fix conflicts and then commit the result.

rm -rf net-2.6.25
git-clone --reference linux-2.6 git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.25

Assuming you have linux-2.6 cloned from Linus.

Dave may have removed patches, combined some, whatever, so I just do the
above procedure when I don't have any pending csets on my local
net-2.6.25 tree.

- Arnaldo
