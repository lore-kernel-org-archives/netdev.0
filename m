From: David Miller <davem@davemloft.net>
Subject: Re: tulip : kernel BUG in tulip_up/tulip_resume
Date: Sat, 21 Nov 2009 11:10:45 -0800 (PST)
Message-ID: <20091121.111045.170330916.davem@davemloft.net>
References: <20090127165727.GA25748@frolo.macqel>
	<20090129210701.GA8092@frolo.macqel>
	<20091108223305.GA21072@frolo.macqel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, kyle@mcmartin.ca,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: phdm@macqel.be
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756786AbZKUTK3@vger.kernel.org>
In-Reply-To: <20091108223305.GA21072@frolo.macqel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe De Muyter <phdm@macqel.be>
Date: Sun, 8 Nov 2009 23:33:05 +0100

> I have just installed 2.6.31 (from opensuse 11.2) one a tulip-equipped
> computer and I get the following error message from the kernel :

I took some looks at this bug.

I simply can't figure out how this is possible.  As both suspend
and resume make sure to make the necessary napi_disable() and
napi_enable() calls, and therefore they should match up and not
trigger this BUG().

I'll try to study the code some more when I get a chance.
