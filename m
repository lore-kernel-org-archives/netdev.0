From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v5] netpoll: fix some sparse warnings in
 various places
Date: Tue, 19 Feb 2013 09:28:20 +0800
Message-ID: <1361237300.25055.0.camel@cr0>
References: <1361157749-9367-1-git-send-email-amwang@redhat.com>
	 <20130218170126.GA1576@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29905 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757400Ab3BSB2e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 20:28:34 -0500
In-Reply-To: <20130218170126.GA1576@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-02-18 at 18:01 +0100, Jiri Pirko wrote:
> >-	return bond->dev->npinfo;
> >+	return rcu_access_pointer(bond->dev->npinfo) != NULL;
>                                                     ^^^^^^^^
> 						    this is not necessary
> 						    (sorry for nitpick)

No problem. Then let's drop this patch. :)
