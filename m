From: David Miller <davem@davemloft.net>
Subject: Re: drivers/connector/cn_queue.c:130: warning: value computed is
 not used
Date: Tue, 30 May 2006 13:11:29 -0700 (PDT)
Message-ID: <20060530.131129.41951475.davem@davemloft.net>
References: <jeac8zg311.fsf@sykes.suse.de>
	<20060530114838.GA20906@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: schwab@suse.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28826
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S932457AbWE3ULC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 May 2006 16:11:02 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060530114838.GA20906@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Tue, 30 May 2006 15:48:38 +0400

> On Tue, May 30, 2006 at 01:34:02PM +0200, Andreas Schwab (schwab@suse.de) wrote:
> > There is no point in testing the atomic value if the result is thrown
> > away.
> 
> It was created to put implicit smp barrier, but it is not needed there.
> Your patch is correct, thank you.

Right, the *_and_test() variants have SMP barriers which the normal
ones do not.  So it is not just a matter of giving a return value
or not, there are real side effect differences.

> > Signed-off-by: Andreas Schwab <schwab@suse.de>
> 
> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

But since you say it doesn't matter I'll apply this.

Thanks!
