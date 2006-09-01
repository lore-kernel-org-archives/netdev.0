From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [GENL]: Provide more information to userspace about registered
	genl families
Date: Fri, 01 Sep 2006 08:48:01 +0200
Message-ID: <1157093281.2878.19.camel@ux156>
References: <20060831212129.GF3470@postel.suug.ch>
	 <1157060812.5297.51.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:43400 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751208AbWIAGrb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 02:47:31 -0400
To: hadi@cyberus.ca
In-Reply-To: <1157060812.5297.51.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-08-31 at 17:46 -0400, jamal wrote:

> I think it would be valuable to specify a set of flags for filtering
> what gets sent to user space instead of unconditionally.
> 
> Example, 
> filter level 0:
>   - what we have before your patch
> filter level 1:
>   - protocol version
>   - header size
>   - maximum number of attributes
> filter level 2:
>   - the rest of the stuff you have
>  
> What netlink does today to filter at user space is something that can be
> avoided with the above (an improvement in my opinion if you have a lot
> of genl items in the kernel).

What I'd personally like to see for nl80211 if we go there is an actual
filter callback, then I could completely avoid the command I have in
there for getting a command list for a given interface, and just filter
out those commands that some interface doesn't support.

johannes
