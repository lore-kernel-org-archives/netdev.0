From: John Ronciak <john.ronciak@gmail.com>
Subject: Re: [RFC: 2.6 patch] remove drivers/net/eepro100.c
Date: Tue, 17 Jan 2006 14:27:16 -0800
Message-ID: <56a8daef0601171427s75894fid0f8c4f9e2b28e50@mail.gmail.com>
References: <20060105181826.GD12313@stusta.de>
	 <20060115161958.07e3c7f1@vitb.dev.rtsoft.ru>
	 <20060115160340.6f8cc7d6@localhost.localdomain>
	 <20060117184834.GD19398@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Vitaly Bordug <vbordug@ru.mvista.com>, jgarzik@pobox.com,
	saw@saw.sw.com.sg, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964870AbWAQW1S@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060117184834.GD19398@stusta.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We don't of any problems reported against e100 that have not been
talked about in this thread (in old ARCH types).  I think the eepro100
driver should be removed from the config "just in case" but we are in
full support of the e100 driver and if somebody says that it's not
working on one of the different ARCHs we are willing to work with them
to get it fixed.  The problem is that we don't have all these
different ARCH systems around to test against.

Another thing is that removal of the driver (or disabling the config)
will hopefully force the issue in that people with these ARCHs will
use the e100 and if they have problems we can get them fixed in the
e100 driver.  At this point nobody seems to be able to define a "real"
problem other than talking about it.


--
Cheers,
John
