From: jamal <hadi@cyberus.ca>
Subject: Re: tc: RTM_GETQDISC causes kernel OOPS
Date: Sat, 22 May 2010 08:31:49 -0400
Message-ID: <1274531509.12793.7.camel@bigi>
References: <20100521224243.GD10247@nicira.com>
	 <1274512687.5020.21.camel@edumazet-laptop>  <4BF7A929.2090007@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Ben Pfaff <blp@nicira.com>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f183.google.com ([209.85.221.183]:42868 "EHLO
	mail-qy0-f183.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755485Ab0EVMby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 May 2010 08:31:54 -0400
Received: by qyk13 with SMTP id 13so3065451qyk.1
        for <netdev@vger.kernel.org>; Sat, 22 May 2010 05:31:53 -0700 (PDT)
In-Reply-To: <4BF7A929.2090007@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-05-22 at 11:51 +0200, Patrick McHardy wrote:

> 
> We already use TCQ_F_BUILTIN in tc_qdisc_dump_ignore(), so I
> think it would be more consistent than checking for a handle
> to use it here as well.

Agree - it is more semantically correct..

I wonder though if it is better to do the check in tc_get_qdisc()
and tc_modify_qdisc()?

cheers,
jamal

