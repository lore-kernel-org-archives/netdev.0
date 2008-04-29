From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] add compat support for getsockopt (MCAST_MSFILTER)
Date: Tue, 29 Apr 2008 03:23:36 -0700 (PDT)
Message-ID: <20080429.032336.113977430.davem@davemloft.net>
References: <20080428.153650.57555735.yoshfuji@linux-ipv6.org>
	<OF81CA6D67.1BAD70DD-ON88257439.00251005-88257439.0025FC25@us.ibm.com>
	<20080428.165220.27263306.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35299
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753576AbYD2KXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 06:23:37 -0400
In-Reply-To: <20080428.165220.27263306.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Mon, 28 Apr 2008 16:52:20 +0900 (JST)

> In article <OF81CA6D67.1BAD70DD-ON88257439.00251005-88257439.0025FC25@us.ibm.com> (at Sun, 27 Apr 2008 23:54:56 -0700), David Stevens <dlstevens@us.ibm.com> says:
> 
> > YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote on 04/27/2008 
> > 11:36:50 PM:
> > 
> > > IMHO, It's much better to split into 2 pathces - bug fixes and
> > > getsockopt() support...
> > 
> >         Ordinarily, I'd agree, but I came across this in the
> > getsockopt code which has the same issue and both the
> > new code and fix require the same #define that's in the
> > getsockopt code. I retested all of it before submitting, too.
> 
> That does not seem to be an excuse, and it is not a
> good practice to me.
> 
> - Several cleanups for the setsockopt compat support.
> - Add compat support for getsockopt (MCAST_MSFILTER)
> 
> Feel free to use these, sync'ed with current net-2.6.

Fair enough, I've applied these two patches.

Thanks everyone!
