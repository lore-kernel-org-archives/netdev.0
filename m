From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa/mv88e6352: make mv88e6352_wait generic
Date: Tue, 27 Jan 2015 00:06:25 -0800 (PST)
Message-ID: <20150127.000625.1477155165878386119.davem@davemloft.net>
References: <1422056081-30088-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@roeck-us.net,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422056081-30088-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri, 23 Jan 2015 18:34:41 -0500

> Some busy bits are available in the global register 1, such as the ATU
> Busy bit. We may want to use this function to wait for them to change,
> so add a new parameter to mv88e6352_wait() instead of hard-coding
> REG_GLOBAL2.
> 
> In the meantime, since the REG_READ() macro already checks for error,
> remove the redundant check for ret < 0.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
