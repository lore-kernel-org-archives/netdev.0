From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] esp6: remove redundant initialization of esph
Date: Mon, 23 Oct 2017 13:21:07 +0200
Message-ID: <20171023112107.GG3323@secunet.com>
References: <20171019130947.30950-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        "Hideaki YOSHIFUJI" <yoshfuji@linux-ipv6.org>,
        <netdev@vger.kernel.org>, <kernel-janitors@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171019130947.30950-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 19, 2017 at 03:09:47PM +0200, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> The pointer esph is being initialized with a value that is never
> read and then being updated.  Remove the redundant initialization
> and move the declaration and initializtion of esph to the local
> code block.
> 
> Cleans up clang warning:
> net/ipv6/esp6.c:562:21: warning: Value stored to 'esph' during its
> initialization is never read
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied to ipsec-next, thanks!
