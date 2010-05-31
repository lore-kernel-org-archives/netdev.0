From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mac8390: change an error return code and some cleanup,
 take 4
Date: Mon, 31 May 2010 08:14:12 -0700 (PDT)
Message-ID: <20100531.081412.27799681.davem@davemloft.net>
References: <alpine.LNX.2.00.1005311905520.469@nippy.intranet>
	<AANLkTilkooBglbk33yDHmk8c_ZdlamOW8FVvuvjQaNsF@mail.gmail.com>
	<1275318493.6503.206.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geert@linux-m68k.org, fthain@telegraphics.com.au,
	p_gortmaker@yahoo.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-m68k@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1275318493.6503.206.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 31 May 2010 08:08:13 -0700

> There are many uses of KERN_DEBUG that are reasonable to have
> always enabled.

Doubtful.

pr_debug() makes a ton of sense as currently implemented.
It's for messages that we want both compile time and
run-time control over.

The case we have here in mac8390 seems like it should stay
as pr_info().  Because 1) it's already controlled by a
run-time knob so controlling it even further is confusing
and 2) the message is "informative", it lets the user know
a feature cannot be enabled, thus pr_info().
