From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH PKT_SCHED 11/17]: Remove checks for impossible conditions
 in ipt action
Date: Thu, 30 Dec 2004 15:25:13 +0100
Message-ID: <41D40FC9.6060902@trash.net>
References: <41D378AB.70204@trash.net> <20041230134029.GX32419@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041230134029.GX32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Patrick McHardy <41D378AB.70204@trash.net> 2004-12-30 04:40
> 
>>-	if (a == NULL || rta == NULL ||
>>-	    rtattr_parse(tb, TCA_IPT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
>>+	if (rtattr_parse(tb, TCA_IPT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
>> 		return -1;
> 
> 
> You might want to use rtattr_parse_nested here (see patch 1 of my latest
> patchset)
> 
> if (rtattr_parse_nested(tb, TCA_IPT_MAX, rta) < 0)
> 
> Purely cosmetic though. It gives a slightly better hint on what is being
> done.

We can do this once your changes are merged (I'll review
them later today). For now I prefer to leave it this way
so I can work on a vanilla tree.

Regards
Patrick
