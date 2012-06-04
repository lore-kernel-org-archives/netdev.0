From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net/hyperv: Use wait_event on outstanding sends
 during device removal
Date: Mon, 04 Jun 2012 11:48:03 -0400 (EDT)
Message-ID: <20120604.114803.742884170282591530.davem@davemloft.net>
References: <1338820532-2345-1-git-send-email-haiyangz@microsoft.com>
	<1338820532-2345-2-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338820532-2345-2-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Mon,  4 Jun 2012 07:35:32 -0700

> +	wait_event(net_device->wait_drain,
> +		atomic_read(&net_device->num_outstanding_sends) == 0);

Please indent this properly.  The goal is not to indent using only
TAB characters, the goal is to line things up to the proper column
using TAB and space characters as needed.

You must make the first character on the second line be at the
first column after the openning parenthesis on the previous line.
