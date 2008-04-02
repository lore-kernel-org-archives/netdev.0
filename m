From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-2.6.26] netlink: make socket filters work on netlink
Date: Wed, 02 Apr 2008 08:25:06 -0400
Message-ID: <1207139106.4451.155.camel@localhost>
References: <47EAAFEC.6000805@trash.net> <20080331123311.64e4ca37@extreme>
	 <47F13E43.2040404@trash.net>
	 <20080331.130757.199769025.davem@davemloft.net>
	 <47F1467F.2080407@trash.net> <1207000143.4424.167.camel@localhost>
	 <47F22211.5080100@trash.net> <1207058646.4424.218.camel@localhost>
	 <47F35933.5080305@trash.net>  <20080402112103.GB20815@postel.suug.ch>
	 <1207137667.4451.143.camel@localhost>  <47F37762.2030705@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:53873 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754303AbYDBMZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 08:25:38 -0400
Received: by an-out-0708.google.com with SMTP id d31so679730and.103
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2008 05:25:35 -0700 (PDT)
In-Reply-To: <47F37762.2030705@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-02-04 at 14:09 +0200, Patrick McHardy wrote:

> Yes, but it was the use of current->pid that was wrong.

There are many many apps out there which still use ioctls - hence the
ambiguity of "is it the kernel that generated the command that caused
the event or was it merely a proxy for some app". 
You need to resolve that. 

> If one of those calls are in a path invoked through netlink
> it should set nlmsg_pid.

Nod - I think thats mostly taken care of; havent looked lately. I know
Alexey didnt object to any patches i submitted that did change how
nlmsg_pid was set on events to match this thought and I cant think of a
reason it would violate any netlink ettiquette. 

Note, I find the whoddunit field (not the pid) to be also useful for
aesthetics and debugging other than for the non-ambiguity in the
filtering.

cheers,
jamal

