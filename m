From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: atm: remove redundant null pointer check on
 dev->name
Date: Thu, 18 Aug 2016 21:04:02 -0700 (PDT)
Message-ID: <20160818.210402.1412369491607112062.davem@davemloft.net>
References: <1471345722-19203-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471345722-19203-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Tue, 16 Aug 2016 12:08:42 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> dev->name is a char array of IFNAMSIZ elements, hence can never be
> null, so the null pointer check is redundant. Remove it.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
