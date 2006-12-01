From: jamal <hadi@cyberus.ca>
Subject: Re: [G[PATCH 1/2][ENETLINK] max cmd boundary chec
Date: Fri, 01 Dec 2006 09:30:27 -0500
Message-ID: <1164983427.3562.36.camel@localhost>
References: <1164972613.3562.7.camel@localhost>
	 <20061201124903.GE8693@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.225]:60331 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1759293AbWLAOah (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 09:30:37 -0500
Received: by nz-out-0102.google.com with SMTP id s1so1543059nze
        for <netdev@vger.kernel.org>; Fri, 01 Dec 2006 06:30:36 -0800 (PST)
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061201124903.GE8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shall i assume that the patch showed up fine i.e no crap like mime?
I still didnt get an echo back, did it make the list?

On Fri, 2006-01-12 at 13:49 +0100, Thomas Graf wrote:

> I can't see why this should be required. genl_register_ops()
> enforces a unique command id 
> and genl_ops->cmd is u8 so there is no way to register more than 
> 256 commands anyway.

By mistake during the tutorial, i had the id at something like 321.
It registered fine but then listing the command showed it with a
different id than what i thought it should be. I think it chops off
all the bystes other than the LS one - which is not a good error
check.
The compiler will whine actually. If you ignore it (perhaps not seeing
the warning in a mass compile) it registers just fine.

cheers,
jamal

