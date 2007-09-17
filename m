From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [v3 PATCH 0/2] Add RCU locking to SCTPaddress management
Date: Mon, 17 Sep 2007 09:44:45 -0400
Message-ID: <46EE84CD.2070104@hp.com>
References: <11897120771278-git-send-email-vladislav.yasevich@hp.com> <20070916.160102.54198849.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:37557 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753166AbXIQNpB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2007 09:45:01 -0400
In-Reply-To: <20070916.160102.54198849.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Thu, 13 Sep 2007 15:34:35 -0400
> 
>> Thanks to Sridhar Samudral and Paul McKenney for all the help and comments.
>> I think this is a final version, unless someone else can spot more problems.
>> I've ran this under heavy load and it the patches behaves well.
>>
>> I think patch 1 is a candidate for 2.6.23 since it fixes a bug, but splitting
>> these seems a bit odd to me.  I'll leave it to DaveM to decide where to
>> put them.
> 
> Since you tested this well, I've decided to put both of these
> patches into net-2.6
> 
> I agree it's stupid to split them up.
> 
> There'll be some merge hassles when I rebase net-2.6.24, but
> that tree is such a monster that this is inevitable for every
> bug fix I queue up for 2.6.23 :-)
> 

Thanks Dave.  If you want me to take a look at these issues, let me know.

-vlad
