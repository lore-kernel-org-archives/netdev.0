From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: usb: asix_devices: fix missing return code check
 on call to asix_write_medium_mode
Date: Wed, 01 Mar 2017 12:52:26 -0500 (EST)
Message-ID: <20170301.125226.289007568565020464.davem@davemloft.net>
References: <20170228115822.20485-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.foss@collabora.com, grundler@google.com, allan@asix.com.tw,
        vpalatin@chromium.org, jarod@redhat.com, peter.chen@nxp.com,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170228115822.20485-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Tue, 28 Feb 2017 11:58:22 +0000

> From: Colin Ian King <colin.king@canonical.com>
> 
> The call to asix_write_medium_mode is not updating the return code ret
> and yet ret is being checked for an error. Fix this by assigning ret to
> the return code from the call asix_write_medium_mode.
> 
> Detected by CoverityScan, CID#1357148 ("Logically Dead Code")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
