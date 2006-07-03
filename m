From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC NET 00/04]: Increase number of possible routing tables
Date: Mon, 03 Jul 2006 13:36:41 +0200
Message-ID: <44A90149.6090304@trash.net>
References: <20060703075259.6286.67397.sendpatchset@localhost.localdomain> <44A8E211.4090005@trash.net> <44A8E57E.4080805@trash.net> <20060703113447.GU14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	greearb@candelatech.com, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50654 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751129AbWGCLhz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 07:37:55 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060703113447.GU14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Patrick McHardy <kaber@trash.net> 2006-07-03 11:38
> 
>>That wasn't entirely true either, its not inet_check_attr but
>>rtnetlink_rcv_message that aborts, and it does this on all
>>kernels. Somehow I thought unknown attributes were usually
>>ignored ..
> 
> 
> This only applies to the first level of rtnetlink attributes,
> when using rtattr_parse() unknown attributes are ignored.
> 
> Once this ugly rta_buf has disappeared it will become more
> consistent.
> 
> Patches look good to me except that new iproute binaries
> won't work with older kernels anymore?

They will as long as this feature isn't used, the RTA_TABLE
attribute is only added to the message when the table id
is > 255. Worked fine during my tests, or are you refering
to something else?

