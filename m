From: Vitaly Bordug <vbordug@ru.mvista.com>
Subject: Re: [RFC: 2.6 patch] remove drivers/net/eepro100.c
Date: Wed, 18 Jan 2006 13:34:37 +0300
Message-ID: <20060118133437.3840827f@vitb.dev.rtsoft.ru>
References: <20060105181826.GD12313@stusta.de>
	<20060115161958.07e3c7f1@vitb.dev.rtsoft.ru>
	<20060115160340.6f8cc7d6@localhost.localdomain>
	<20060117184834.GD19398@stusta.de>
	<56a8daef0601171427s75894fid0f8c4f9e2b28e50@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>,
	Stephen Hemminger <shemminger@osdl.org>, jgarzik@pobox.com,
	saw@saw.sw.com.sg, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964840AbWARKeq@vger.kernel.org>
To: John Ronciak <john.ronciak@gmail.com>
In-Reply-To: <56a8daef0601171427s75894fid0f8c4f9e2b28e50@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 17 Jan 2006 14:27:16 -0800
John Ronciak <john.ronciak@gmail.com> wrote:

> We don't of any problems reported against e100 that have not been
> talked about in this thread (in old ARCH types).  I think the eepro100
> driver should be removed from the config "just in case" but we are in
> full support of the e100 driver and if somebody says that it's not
> working on one of the different ARCHs we are willing to work with them
> to get it fixed.  The problem is that we don't have all these
> different ARCH systems around to test against.
> 
> Another thing is that removal of the driver (or disabling the config)
> will hopefully force the issue in that people with these ARCHs will
> use the e100 and if they have problems we can get them fixed in the
> e100 driver.  At this point nobody seems to be able to define a "real"
> problem other than talking about it.

Ok then, let's go ahead, but 
I vote for config exclusion as a first step,
so if anybody will run into problems, will use old mature stuff until e100 get fixed.

Due to rollback the removed driver - back and forth in killing/resurrecting stuff is not a good example to follow within the kernel.

Generally speaking, e100 should replace eepro*, but I can see no reason for rush in doing that one-step.


-- 
Sincerely, 
Vitaly
