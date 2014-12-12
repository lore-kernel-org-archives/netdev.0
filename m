From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Remove redundant function
Date: Fri, 12 Dec 2014 15:16:26 -0500 (EST)
Message-ID: <20141212.151626.1534262330967192209.davem@davemloft.net>
References: <20141212123432.GA12765@sloth>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cooldavid@cooldavid.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: lambert.quentin@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141212123432.GA12765@sloth>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Quentin Lambert <lambert.quentin@gmail.com>
Date: Fri, 12 Dec 2014 13:34:32 +0100

> tasklet_hi_enable and tasklet_enable are redundant. Since
> tasklet_hi_enable is used only 6 times in 1 file, the first
> patch changes calls to the function with calls to tasklet_enable.
> 
> The second patch removes tasklet_hi_enable definition.

This is pretty simple and straightforward, so I hope nobody minds
my merging this via my networking tree.

Series applied, thanks.
