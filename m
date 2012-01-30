From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/1] wireless: remove return in _rtl_pci_switch_clk_req
Date: Mon, 30 Jan 2012 15:45:03 -0800
Message-ID: <1327967103.4230.7.camel@joe2Laptop>
References: <1327927591-28070-1-git-send-email-devendra.aaru@gmail.com>
	 <4F27294D.30302@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Devendra.Naga" <devendra.aaru@gmail.com>,
	chaoming_li@realsil.com.cn, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F27294D.30302@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-01-30 at 17:35 -0600, Larry Finger wrote:
> The patch is OK, but the patch subject is bad. You should have "[PATCH] 
> rtlwifi:...". Your patch is for rtlwifi, not wireless.

Hi Devendra.

A reasonable rule of thumb is use the deepest directory
path basename you can to prefix the patch.
Something like:

[PATCH] $(basename $(dirname $file)): terse description

If you are patching drivers/net/ethernet/realtek/apt.c
this becomes:

[PATCH] realtek: terse description

There are some exceptions though.  One of them
is if the patch is in staging, prefix with
[PATCH] staging: $(basename $(dirname $file)): description

cheers, Joe
