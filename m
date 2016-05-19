From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: rsi: eliminate superfluous NULL check
Date: Thu, 19 May 2016 11:31:35 -0700 (PDT)
Message-ID: <20160519.113135.2232299642544593300.davem@davemloft.net>
References: <1463524241-11351-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kvalo@codeaurora.org, hofrat@osadl.org, johannes.berg@intel.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xypron.glpk@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463524241-11351-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Date: Wed, 18 May 2016 00:30:41 +0200

> msg is dereferenced before checking against NULL, e.g.
> when assigning pad_bytes.
> Remove the superfluous check in function rsi_mgmt_pkt_to_core.
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

I'll let the wireless folks pick this up.
