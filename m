From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFC PATCH linux-next] et131x: Promote staging et131x driver to
 drivers/net
Date: Tue, 23 Sep 2014 21:02:42 +0200
Message-ID: <20140923190242.GA8096@electric-eye.fr.zoreil.com>
References: <1411421283-25073-1-git-send-email-mark.einon@gmail.com>
 <20140923072251.GD4657@distanz.ch>
 <20140923094614.GA5130@leicester.auvation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tobias Klauser <tklauser@distanz.ch>, gregkh@linuxfoundation.org,
	davem@davemloft.net, devel@driverdev.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mark Einon <mark.einon@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140923094614.GA5130@leicester.auvation.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Einon <mark.einon@gmail.com> :
[...]
> > No need for the #define here, just assigne et131x_pm_ops to .driver.pm
> > directly, its members will be NULL and thus never called. Also, you can
> > make et131x_pm_ops const.
> 
> Ok, I can change this.
> 
> Btw, this appears to be a fairly standard way of using .driver.pm among
> ethernet drivers, e.g. see 3com/3c59x.c, atheros, marvell... - perhaps
> there is a case for changing all instances of this code?

How about kernel tinification ?

-- 
Ueimor
