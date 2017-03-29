From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] VSOCK: remove unnecessary ternary operator on return
 value
Date: Tue, 28 Mar 2017 21:49:58 -0700 (PDT)
Message-ID: <20170328.214958.1031055485189943869.davem@davemloft.net>
References: <20170328155424.22873-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhansen@vmware.com, aditr@vmware.com, julia.lawall@lip6.fr,
        stefanha@redhat.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170328155424.22873-1-colin.king@canonical.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Tue, 28 Mar 2017 16:54:24 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> Rather than assign the positive errno values to ret and then
> checking if it is positive and flip the sign, just set ret to
> be the -ve errno value.
> 
> Detected by CoverityScan, CID#986649 ("Logically Dead Code")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Just return the error directly instead of having this variable.

Thanks.
