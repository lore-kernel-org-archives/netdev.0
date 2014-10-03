From: Joe Perches <joe@perches.com>
Subject: Re: [patch] checkpatch: remove the ether_addr_copy warning
Date: Fri, 03 Oct 2014 07:22:27 -0700
Message-ID: <1412346147.3247.97.camel@joe-AO725>
References: <20141003093505.GA7393@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andy Whitcroft <apw@canonical.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	gregkh@linuxfoundation.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20141003093505.GA7393@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-10-03 at 12:35 +0300, Dan Carpenter wrote:
> Most people sending checkpatch.pl fixes don't know how to verify the
> alignment.  This checkpatch warning just encourages newbies to try
> introduce bugs.  Patch submitters tell us that they just sed the code
> and it's the job for the maintainer to check that it's correct.

I haven't seen many instances of bad patch submittals
on netdev.  Is this mostly an issue for staging?

Maybe a downgrade to CHK requiring --strict is OK.

> If you want to work on these then you can get the same information by
> typing `grep -nw memcpy drivers/net/ -R | grep ETH_ALEN`

That's not much of an argument for or against anything in
checkpatch as every operation done by it can be reproduced
by a series of grep operations.


