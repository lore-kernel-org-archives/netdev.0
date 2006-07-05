From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 1/3] [PKT_SCHED]: Fix illegal memory dereferences when
	dumping actions
Date: Tue, 04 Jul 2006 21:34:40 -0400
Message-ID: <1152063280.5199.1.camel@jzny2>
References: <20060704220504.787776000@postel.suug.ch>
	 <20060704220549.952720000@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:57218 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932436AbWGEBen
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jul 2006 21:34:43 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FxwHx-000139-SE
	for netdev@vger.kernel.org; Tue, 04 Jul 2006 21:34:49 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060704220549.952720000@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-05-07 at 00:00 +0200, Thomas Graf wrote:
> plain text document attachment (act_fix_dump_null_deref)
> The TCA_ACT_KIND attribute is used without checking its
> availability when dumping actions therefore leading to a
> value of 0x4 being dereferenced.
> 
> The use of strcmp() in tc_lookup_action_n() isn't safe
> when fed with string from an attribute without enforcing
> proper NUL termination.
> 
> Both bugs can be triggered with malformed netlink message
> and don't require any privileges.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 

Good catch.

Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>


cheers,
jamal

