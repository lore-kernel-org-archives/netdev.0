From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.29.1: unregister_netdevice problem
Date: Sat, 16 May 2009 09:06:29 +0200
Message-ID: <4A0E65F5.1040906@gmail.com>
References: <49F76BF6.4040709@gmail.com> <20090429054510.GA8267@night.netis.ru> <20090429090809.GA2995@ami.dom.local> <20090508062640.GA4555@night.netis.ru> <20090508104628.GA6287@ff.dom.local> <20090510073559.GA8929@night.netis.ru> <20090510124641.GA2978@ami.dom.local> <20090515071946.GA15669@night.netis.ru> <20090515080649.GA5469@ff.dom.local> <20090515085414.GA27744@night.netis.ru> <20090515101209.GA6367@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Alexander V. Lukyanov" <lav@netis.ru>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f174.google.com ([209.85.218.174]:61470 "EHLO
	mail-bw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475AbZEPHHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2009 03:07:50 -0400
In-Reply-To: <20090515101209.GA6367@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 05/15/2009 12:12 PM:

> On Fri, May 15, 2009 at 12:54:14PM +0400, Alexander V. Lukyanov wrote:
>> On Fri, May 15, 2009 at 08:06:49AM +0000, Jarek Poplawski wrote:
>>> On Fri, May 15, 2009 at 11:19:46AM +0400, Alexander V. Lukyanov wrote:
>>> ...
>>>> Looks like 2.6.28.10 does not have this refcnt problem. Also, after I have
>>>> reversed net/ipv4/route.c changes from 2.6.29, the problem does not occur either.
>>> Very nice work! It should be a piece of cake now - there were not much
>>> changes. I'll look at it, as usual ;-), but, of course if it's
>>> possible, it would be great to try "in the meantime" with reverted the
>>> biggest of them append below.
>> I suspect the problem occurs when cand==rthi.
> 
> Looks like good catch! (But there could be more than this.) Then, of
> course it would be interesting to try first some fix (like nulling
> rthi after rt_free(cand), I guess).


On the other hand, since this looks like quite obvious bug (even if it
doesn't fix your problem), feel free to send here a patch fixing it any
way you like without waiting for the final test results (Cc-ing authors
of the offending patch, I hope).

Jarek P.
