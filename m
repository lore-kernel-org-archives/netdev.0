From: Alexander Stein <alexander.stein@systec-electronic.com>
Subject: Re: [PATCH] rtlwifi: pass struct rtl_stats by reference as it is more efficient
Date: Mon, 22 Feb 2016 07:51:08 +0100
Message-ID: <1498532.AoNxxa1Kry@ws-stein>
References: <1456006227-10709-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Colin King <colin.king@canonical.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>,
	Priit Laes <plaes@plaes.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456006227-10709-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 20 February 2016 22:10:27, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> passing rtl_stats by value is inefficient; the structure is over 300
> bytes in size and generally just one field (packet_report_type)
> is being accessed, so the pass by value is a relatively large overhead.
> This change just affects just the rx_command_packet calls.

Why not using a const pointer?

Best regards,
Alexander
