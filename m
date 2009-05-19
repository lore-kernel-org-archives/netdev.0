From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][be2net] remove napi in the tx path
Date: Mon, 18 May 2009 19:23:09 -0700 (PDT)
Message-ID: <20090518.192309.109435829.davem@davemloft.net>
References: <20090519013616.GA25903@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50054
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752557AbZESCXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 22:23:11 -0400
In-Reply-To: <20090519013616.GA25903@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Actually, I'm not applying this patch at all.

It's garbage.

First of all, your commit message is way too terse.  Why did
you do these things, what are the reasons?  You don't explain
anything.  If it's for performance reasons, you give no
information about that.

Second of all, the change does two things.  One of which you
don't even mention in your subject line, all of this LRO stuff.

Third of all, module parameters ARE NOT THE WAY TO CONTROL LRO!
We have an ethtool command to turn it on and off, via the
ethtool_ops->{set,get}_flags() methods.  So this part of your
change is totally unacceptable.

Your patch submissions, I have to say, are horrible.  Your
patches don't apply cleanly to the net trees, your commit
messages are one-liners at best, and your patches do multiple
unrelated things at the same time.
