From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 1/2] bluetooth: Use more current logging styles
Date: Mon, 13 Feb 2012 08:21:46 +0100
Message-ID: <1329117706.28848.55.camel@aeonflux>
References: <cover.1329102581.git.joe@perches.com>
	 <44b8744770a55924c68f8ad0ca274816d2d6148f.1329102581.git.joe@perches.com>
	 <1329114913.28848.50.camel@aeonflux> <1329115573.30878.1.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329115573.30878.1.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

> > Why is this a good thing?
> 
> It's more similar to the rest of the <foo>_<level> uses.
> Other than that, it's a little smaller.
> 
> > And in your patch we have bt_err not having \n\n in the end.
> 
> There shouldn't be a newline at all with the
> actual functions bt_err or bt_info except
> at the uses.

then you might wanna read your patch again ;)

> This is the style used in pr_<level> so that
> it becomes possible to use pr_cont.

Since we don't have a bt_cont, I don't see why bother changing this
right now.

Regards

Marcel
