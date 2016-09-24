From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: fix -ve error check on a signed iq
Date: Sat, 24 Sep 2016 08:31:49 -0400 (EDT)
Message-ID: <20160924.083149.439186691430439270.davem@davemloft.net>
References: <20160923134513.21345-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160923134513.21345-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Fri, 23 Sep 2016 14:45:13 +0100

> -static unsigned int get_filter_steerq(struct net_device *dev,
> +static int get_filter_steerq(struct net_device *dev,
>  				      struct ch_filter_specification *fs)

If you change the location of the openning parenthesis of the first
line, you must reindent the second line so that the arguments are
placed preciely at the column following that openning parenthesis.
