From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH v2 5/6] net-PPP: Delete an unnecessary assignment in
 mppe_alloc()
Date: Fri, 5 Dec 2014 16:57:23 +0300
Message-ID: <20141205135723.GE4912@mwanda>
References: <5317A59D.4@users.sourceforge.net>
 <547B4886.4080406@users.sourceforge.net>
 <547B496E.604@users.sourceforge.net>
 <547C5CBC.6060607@cogentembedded.com>
 <547C82A6.2030808@users.sourceforge.net>
 <547CA157.1080401@cogentembedded.com>
 <5480DA32.8000201@users.sourceforge.net>
 <5480DDC1.6040101@users.sourceforge.net>
 <20141205122214.GB4912@mwanda>
 <5481A8AE.9050506@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5481A8AE.9050506@users.sourceforge.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 05, 2014 at 01:44:30PM +0100, SF Markus Elfring wrote:
> >> The data structure element "arc4" was assigned a null pointer by the
> >> mppe_alloc() function if a previous function call "crypto_alloc_blkcipher"
> >> failed.
> > 
> > crypto_alloc_blkcipher() returns error pointers and not NULL.
> 
> That is true.
> 

Oh.  In that case, I misunderstood what you wrote.  Looking at it now,
this patch is actually ok.

regards,
dan carpenter

