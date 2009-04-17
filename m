From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29
Date: Sat, 18 Apr 2009 00:43:09 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0904172354160.2522@wrl-59.cs.helsinki.fi>
References: <alpine.DEB.1.10.0904161504090.15835@qirst.com>
 <49E786FE.6090304@cosmosbay.com> <alpine.DEB.1.10.0904161532350.22449@qirst.com>
 <20090416.154701.21872281.davem@davemloft.net> <alpine.DEB.1.10.0904170943300.11877@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dada1@cosmosbay.com,
	rick.jones2@hp.com, Netdev <netdev@vger.kernel.org>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35362 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753022AbZDQVnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 17:43:11 -0400
In-Reply-To: <alpine.DEB.1.10.0904170943300.11877@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Apr 2009, Christoph Lameter wrote:

> On Thu, 16 Apr 2009, David Miller wrote:
> 
> > More seriously, it's going to be hard to isolate anything
> > unless you concern yourself with changes to one thing
> > on one system at a time.
> 
> Only the kernel version was changed on both systems. Changing only a
> single system would have meant considering complex interactions between
> the network layers of varying versions which would make
> the problem even more difficult to track down.
> 
> I changed one thing: The kernel version.

No we're not talking about n^2 results here but claiming that changing 
only a single network endpoint makes things _more complex_ is quite bogus? 
Like it or not, those network layers you mention are still separated by 
pretty standadized medium whose encoding and timing is certainly quite 
independent of the kernel version :-).

I'd suggest you take the latest and v2.6.22 and run the remaining two 
mixed setups (I hope your scripts are not too fixed with identical 
versions... :-)).

-- 
 i.
