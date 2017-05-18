From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] liquidio: make the spinlock octeon_devices_lock static
Date: Thu, 18 May 2017 11:24:51 -0400 (EDT)
Message-ID: <20170518.112451.1077297322113539139.davem@davemloft.net>
References: <20170518091401.13013-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: derek.chickles@caviumnetworks.com,
        satananda.burla@caviumnetworks.com,
        felix.manlunas@caviumnetworks.com,
        raghu.vatsavayi@caviumnetworks.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170518091401.13013-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Thu, 18 May 2017 10:14:01 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> octeon_devices_lock can be made static as it does not need to be
> in global scope.
> 
> Cleans up sparse warning: "warning: symbol 'octeon_devices_lock'
> was not declared. Should it be static?"
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
