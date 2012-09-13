From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: Re: [PATCH 9/9] drivers/isdn/gigaset/common.c: Remove useless kfree
Date: Thu, 13 Sep 2012 11:27:49 +0200
Message-ID: <CA+MoWDqiudaBC=sLUuQABTZHp2yUTVB+RY73no8s61fsG7vaZQ@mail.gmail.com>
References: <1347462407-13499-9-git-send-email-peter.senna@gmail.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B6FEE@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Hansjoerg Lipp <hjlipp@web.de>, kernel-janitors@vger.kernel.org,
	Tilman Schmidt <tilman@imap.cc>,
	Karsten Keil <isdn@linux-pingi.de>,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6FEE@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Seems to me that (assuming kfree(NULL) is ok) the kfree()
> is best left in - just in case some other error path is
> added after drv->cs is assigned.
> Better safe than a memory leak.

I'm not sure if I got your point. Now the label "error:" is only
reached if drv->cs is NULL. There is not other way to move to error:
unless drv->cs is NULL. Why wouldn't be safe to remove the
kfree(drv->cs) when drv->cs is NULL?


-- 
Peter
