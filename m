From: Pavel Roskin <proski@gnu.org>
Subject: Re: pull request: wireless-2.6 2008-08-04
Date: Mon, 04 Aug 2008 23:04:24 -0400
Message-ID: <20080804230424.26ghqn81s0480ogk-cebfxv@webmail.spamcop.net>
References: <20080804193753.GA30345@tuxdriver.com>
	<20080804.150147.78586437.davem@davemloft.net>
	<20080805021710.GA21731@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763407AbYHEDEq@vger.kernel.org>
In-Reply-To: <20080805021710.GA21731@tuxdriver.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting "John W. Linville" <linville@tuxdriver.com>:

> Sure, np.  I created a "no-ath9k" branch in case you are feeling
> frisky -- it is the same except for omitting the list.h changes,
> the ath5k pci table change, and the new ath9k driver.

You can keep the ath5k PCI table change.  Those devices are not  
supported by ath5k and not going to be supported, especially since  
ath9k supports them.  They are not even listed on  
http://wireless.kernel.org/en/users/Drivers

The patch should go upstream quickly, so that potential ath9k users  
don't have to blacklist ath5k.

-- 
Regards,
Pavel Roskin
