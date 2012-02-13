From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/2] bluetooth: Use more current logging styles
Date: Sun, 12 Feb 2012 22:46:13 -0800
Message-ID: <1329115573.30878.1.camel@joe2Laptop>
References: <cover.1329102581.git.joe@perches.com>
	 <44b8744770a55924c68f8ad0ca274816d2d6148f.1329102581.git.joe@perches.com>
	 <1329114913.28848.50.camel@aeonflux>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329114913.28848.50.camel@aeonflux>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-02-13 at 07:35 +0100, Marcel Holtmann wrote:
> Why is this a good thing?

It's more similar to the rest of the <foo>_<level> uses.
Other than that, it's a little smaller.

> And in your patch we have bt_err not having \n\n in the end.

There shouldn't be a newline at all with the
actual functions bt_err or bt_info except
at the uses.

This is the style used in pr_<level> so that
it becomes possible to use pr_cont.

> Size numbers look good. So I am all for this, but not just in one big
> patch.

I think the size is more or less irrelevant.
