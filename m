From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mac8390: fix pr_info() calls and change return code
Date: Fri, 16 Apr 2010 13:28:55 -0700 (PDT)
Message-ID: <20100416.132855.230883346.davem@davemloft.net>
References: <alpine.OSX.2.00.1004161403160.271@localhost>
	<1271392454.2298.37.camel@Joe-Laptop.home>
	<alpine.OSX.2.00.1004162340370.271@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, p_gortmaker@yahoo.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-m68k@vger.kernel.org
To: fthain@telegraphics.com.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.OSX.2.00.1004162340370.271@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Finn Thain <fthain@telegraphics.com.au>
Date: Fri, 16 Apr 2010 23:57:34 +1000 (EST)

> 
> On Thu, 15 Apr 2010, Joe Perches wrote:
> 
>> ...Why is it better to use -EBUSY?
> 
> Nubus slots are geographically addressed and their irqs are equally 
> inflexible. -EAGAIN is misleading because retrying will not help fix 
> whatever bug caused the irq to unavailable.

This is exactly the kind of background information and verbose
explanation that belongs in the commit message.

Yet in your recent version of the patch, you're still being extremely
terse as per the reasoning for using -EBUSY

Just saying it's "misleading" doesn't tell anyone anything if they
have to go back in the commit history and try to figure out why this
change was made if it's causing problems later.

Please make the verbose and complete explanation in your commit
message, and resubmit your patch.

I just want to point out that with all the trouble you gave about
Joe's work, you're having one heck of a time even submitting your
changes properly. :-)

Thanks.
