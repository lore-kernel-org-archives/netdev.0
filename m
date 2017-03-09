From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND v1] qed: Fix copy of uninitialized memory
Date: Thu, 09 Mar 2017 13:18:32 -0800 (PST)
Message-ID: <20170309.131832.1359068981842523227.davem@davemloft.net>
References: <20170307164625.6372-1-robert.foss@collabora.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@cavium.com, Ariel.Elior@cavium.com,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: robert.foss@collabora.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170307164625.6372-1-robert.foss@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Foss <robert.foss@collabora.com>
Date: Tue,  7 Mar 2017 11:46:25 -0500

> In qed_ll2_start_ooo() the ll2_info variable is uninitialized and then
> passed to qed_ll2_acquire_connection() where it is copied into a new
> memory space.
> 
> This shouldn't cause any issue as long as non of the copied memory is
> every read.
> But the potential for a bug being introduced by reading this memory
> is real.
> 
> Detected by CoverityScan, CID#1399632 ("Uninitialized scalar variable")
> 
> Signed-off-by: Robert Foss <robert.foss@collabora.com>

Applied.
