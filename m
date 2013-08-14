From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet/arc/arc_emac - fix NAPI "work > weight"
 warning
Date: Tue, 13 Aug 2013 17:01:05 -0700 (PDT)
Message-ID: <20130813.170105.601411361110484740.davem@davemloft.net>
References: <1376399076-9320-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vineet.Gupta1@synopsys.com,
	Mischa.Jonker@synopsys.com, arnd@arndb.de, grant.likely@linaro.org,
	rob.herring@calxeda.com, paul.gortmaker@windriver.com,
	linux-kernel@vger.kernel.org
To: Alexey.Brodkin@synopsys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376399076-9320-1-git-send-email-abrodkin@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Date: Tue, 13 Aug 2013 17:04:36 +0400

> Initially I improperly set a boundary for maximum number of input
> packets to process on NAPI poll ("work") so it might be more than
> expected amount ("weight").
> 
> This was really harmless but seeing WARN_ON_ONCE on every device boot is
> not nice. So trivial fix ("<" instead of "<=") is here.
> 
> Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>

Applied, thanks.
