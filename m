From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mkiss: remove redundant assignment of len to ax->mtu
Date: Wed, 01 Nov 2017 12:10:04 +0900 (KST)
Message-ID: <20171101.121004.1862713849418258600.davem@davemloft.net>
References: <20171029133025.6665-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas@osterried.de, stephen@networkplumber.org,
        johannes.berg@intel.com, ralf@linux-mips.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171029133025.6665-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Sun, 29 Oct 2017 13:30:25 +0000

> From: Colin Ian King <colin.king@canonical.com>
> 
> Variable len is being assigned a value that is never read,
> hence the assignment is redundant and can be removed. Cleans
> up clang warning:
> 
> drivers/net/hamradio/mkiss.c:443:3: warning: Value stored to
> 'len' is never read
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
