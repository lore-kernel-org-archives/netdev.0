From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: Do not trigger BUG_ON when deleting assoc without primary path
Date: Sat, 19 Oct 2013 13:31:45 -0400
Message-ID: <2284704C-D6DC-4956-8389-11C365373E9D@gmail.com>
References: <1382031042-27339-1-git-send-email-vyasevich@gmail.com> <20131018.163843.394049429297788865.davem@davemloft.net>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"Mark.Thomas@metaswitch.com" <Mark.Thomas@metaswitch.com>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:43803 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753135Ab3JSRbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 13:31:50 -0400
In-Reply-To: <20131018.163843.394049429297788865.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Oct 18, 2013, at 4:38 PM, David Miller <davem@davemloft.net> wrote:

> From: Vlad Yasevich <vyasevich@gmail.com>
> Date: Thu, 17 Oct 2013 13:30:42 -0400
> 
>> It is possible to enter sctp_cmd_delete_tcb() without having a
>> primary path.  The situations this most often happens in is
>> when duplication cookie processing is triggered.  In this
>> case, we are deleting a temporarily created association that
>> is not fully populated.   Additially, at the time we
>> are deleting the offending association, it is really too
>> late to issue a BUG!
> 
> Vlad, it looks like you and Daniel are working on an alternative
> scheme to handle this issue.  So I just toss this patch for now?

yep.  toss for now.  

thanks
vlad
