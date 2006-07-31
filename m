From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'bcm43xx' branch of wireless-2.6?
Date: Mon, 31 Jul 2006 16:01:43 -0400
Message-ID: <44CE61A7.4010207@garzik.org>
References: <20060728002206.GA11621@tuxdriver.com> <20060728002358.GB11621@tuxdriver.com> <20060728003753.GC11621@tuxdriver.com> <20060731191014.GD10138@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:61576 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932190AbWGaUBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 16:01:46 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060731191014.GD10138@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> Jeff, if a 10ms maximum delay is still acceptable to you, then please
> pull from the bcm43xx branch of wireless-2.6 into the upstream branch
> of netdev-2.6.

Just to be clear, 'upstream' not 'upstream-fixes', correct?


> P.S. FWIW, I'm still not totally happy w/ the (potential for a)
> long busy wait.  But, this series of patches makes things better by
> 100x over what is currently in the tree.  So, it seems worthwhile.
> I'll keep further reductions as an item on my TODO list, FWIW... :-)

Agreed.  And there are some existing busy-waits that (1) _obviously_ 
need to be converted to mdelay(), and (2) eventually need to be 
converted to msleep().

Overall, the Linux kernel community consensus is that long synchronous 
delays spinning the CPU should be avoided.

	Jeff



