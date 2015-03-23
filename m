From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable: warnings caused by "rhashtable: Fix use-after-free
 in rhashtable_walk_stop"
Date: Tue, 24 Mar 2015 08:55:13 +1100
Message-ID: <20150323215513.GA20128@gondor.apana.org.au>
References: <55105B2E.1070409@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55105B2E.1070409@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 23, 2015 at 02:27:58PM -0400, Sasha Levin wrote:
> Hi all,
> 
> Commit 963ecbd41a ("rhashtable: Fix use-after-free in rhashtable_walk_stop") is causing
> RCU warnings since the code now locks a mutex (which might sleep) within an RCU critical
> section within rhashtable_walk_stop().

OK I will add a spin lock to bucket_table for this.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
