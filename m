From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] liquidio CN23XX: check if PENDING bit is clear using
 logical and
Date: Fri, 18 Nov 2016 14:04:16 -0500 (EST)
Message-ID: <20161118.140416.729970601759105910.davem@davemloft.net>
References: <20161118184532.5282-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: derek.chickles@caviumnetworks.com,
        satananda.burla@caviumnetworks.com,
        felix.manlunas@caviumnetworks.com,
        raghu.vatsavayi@caviumnetworks.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161118184532.5282-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Fri, 18 Nov 2016 18:45:32 +0000

> From: Colin Ian King <colin.king@canonical.com>
> 
> the mbox state should be bitwise anded rather than logically anded
> with OCTEON_MBOX_STATE_RESPONSE_PENDING. Fix this by using the
> correct & operator instead of &&.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Dan Carpenter already submitted a fix for this.
