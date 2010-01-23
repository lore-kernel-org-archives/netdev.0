From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [RFC, PATCH net-next-2.6] net: introduce a macro to traverse
 through uc_list easily
Date: Sat, 23 Jan 2010 19:28:15 +0100
Message-ID: <20100123182814.GA2613@psychotron.redhat.com>
References: <20100122151301.GC2609@psychotron.redhat.com>
 <20100123.020140.231150448.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12094 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752103Ab0AWS2V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jan 2010 13:28:21 -0500
Content-Disposition: inline
In-Reply-To: <20100123.020140.231150448.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Jan 23, 2010 at 11:01:40AM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jpirko@redhat.com>
>Date: Fri, 22 Jan 2010 16:13:02 +0100
>
>> Therefore that would be good to introduce a macro that can be used to traverse
>> through addresses in the list without caller knowing anything about the type of
>> the list. I think this kind of an abstraction is appropriate on this place.
>> Also during the phase of changing, the macro can use the original list and onc ...
>> What do you think about this? Please comment.
>
>Yes this is the way to do it, three steps:
>
>1) Add interface macros that iterate using the existing
>   datastructure
>
>2) Convert drivers to use #1
>
>3) Convert to list_head
>

Yes, I know the drill. I just wanted to be sure that final macro (kinda ugly)
will be accepted... I'll first make uc_list part (and that's how mc_list part
will lool like finally). Will post soon.

Thanks

Jirka
