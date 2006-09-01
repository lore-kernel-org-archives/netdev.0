From: jamal <hadi@cyberus.ca>
Subject: Re: [GENL]: Provide more information to userspace about registered
	genl families
Date: Fri, 01 Sep 2006 09:00:23 -0400
Message-ID: <1157115624.5057.89.camel@jzny2>
References: <20060831212129.GF3470@postel.suug.ch>
	 <1157060812.5297.51.camel@jzny2>  <1157093281.2878.19.camel@ux156>
	 <1157113331.5057.67.camel@jzny2>  <1157113517.2878.55.camel@ux156>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:25479 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1750808AbWIANAc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 09:00:32 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GJ8dO-0001XV-5S
	for netdev@vger.kernel.org; Fri, 01 Sep 2006 09:00:34 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1157113517.2878.55.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-01-09 at 14:25 +0200, Johannes Berg wrote:
> On Fri, 2006-09-01 at 08:22 -0400, jamal wrote:
> 

> > Sorry, I havent had time to look at that code (is it in Daves tree?); 
> 
> No, it's not in any tree yet.
> 

Could you point me to it? I can look at it over the weekend.

> > if
> > i understand you correctly - you have a superset of commands, and some
> > users of those commands can only implement a subset?
> 
> precisely.


It may be we need to add another feature to genl to accomodate this.
Example by setting a flag to indicate supportability. However, it does
sound like this is something your code needs to own in a capability set
structure somewhere. I cant tell without looking at the code. 

cheers,
jamal

