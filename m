From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 19:18:48 +0200
Message-ID: <44A55CF8.2040509@trash.net>
References: <1151623394.8922.27.camel@jzny2> <20060629233933.GB14627@postel.suug.ch> <1151625826.8922.58.camel@jzny2> <20060630004640.GC14627@postel.suug.ch> <1151629890.8922.121.camel@jzny2> <20060630130811.GE14627@postel.suug.ch> <1151675843.5270.18.camel@jzny2> <20060630141531.GG14627@postel.suug.ch> <1151678118.5270.45.camel@jzny2> <20060630163229.GH14627@postel.suug.ch> <20060630171348.GI14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:21634 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932620AbWF3RSu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 13:18:50 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060630171348.GI14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Thomas Graf <tgraf@suug.ch> 2006-06-30 18:32
> 
>>Anyways, I give up. Last time I've been running after you trying
>>to fix the many bugs you leave behind. Ever noticed that whenever
>>you add some new code it's someone else following up with tons of
>>small bugfix patches having a hard time trying to figure out the
>>actual intent. I'll just duplicate the code for my purpose, so
>>much easier.
> 
> 
> There you go, leaves ifb broken as-is, at least prevents it
> from crashing randomly when the input_dev disappears.

That would be a pity. After this patch has been ACKed, could we start
over with the other bugs one at a time? I wasn't really able to gather
the problems from this thread, but some of the behaviour you mentioned
does seem questionable.

