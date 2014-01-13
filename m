From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] sh_eth: fix garbled TX error message
Date: Mon, 13 Jan 2014 08:51:58 -0800
Message-ID: <1389631918.24849.20.camel@joe-AO722>
References: <201401110241.49471.sergei.shtylyov@cogentembedded.com>
	 <20140113004532.GJ15296@verge.net.au> <1389576241.24849.10.camel@joe-AO722>
	 <52D41117.3040809@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0018.hostedemail.com ([216.40.44.18]:59664 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754980AbaAMQwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 11:52:03 -0500
In-Reply-To: <52D41117.3040809@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-01-13 at 20:15 +0400, Sergei Shtylyov wrote:
> On 13-012014 5:24, Joe Perches wrote:
> >>> sh_eth_error() in case of a TX error tries to print a message using 2 dev_err()
> >>> calls with the first string not finished by '\n', so that the resulting message
> >>> would inevitably come out garbled, with something like "3net eth0: " inserted
> >>> in the middle.  Avoid that by merging 2 calls into one.
> 
> > I believe this interleaving should not happen since
> > commit e28d713704117bca0820c732210df6075b09f13b
> > (2.6.31 days)
> 
>     I believe you have given me the wrong commit, which has nothing to do the 
> the newline problem per se. It just adds KERN_DEFAULT. I was able to find the 
> correct commit though: it's the parent of the commit you cited, 

Yeah, I was just scanning the printk commit logs
and looked for the first one that said something
like force newline.

> I should have tested my assumption beforehand... 

Always a good thing.

> (I'd like to merge these 
> dev_err() calls still though).

Yes, the dev_err calls should be merged.

About the other stuff, what/when ever...

cheers, Joe
