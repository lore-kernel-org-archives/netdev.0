From: jamal <hadi@cyberus.ca>
Subject: Re: [G[PATCH 1/2][ENETLINK] max cmd boundary chec
Date: Fri, 01 Dec 2006 09:52:38 -0500
Message-ID: <1164984758.3562.57.camel@localhost>
References: <1164972613.3562.7.camel@localhost>
	 <20061201124903.GE8693@postel.suug.ch> <1164983427.3562.36.camel@localhost>
	 <20061201144058.GG8693@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.236]:54991 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1758889AbWLAOwp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 09:52:45 -0500
Received: by nz-out-0102.google.com with SMTP id s1so1547366nze
        for <netdev@vger.kernel.org>; Fri, 01 Dec 2006 06:52:44 -0800 (PST)
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061201144058.GG8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-01-12 at 15:40 +0100, Thomas Graf wrote:

> There is no way to fix this in the interface. If you do u8 op = 312
> and ignore the compiler warning which states that the value has been
> truncated it can't be helped, the interface will see op = 56 

Indeed I think this is what i saw. 
312 == 0x138
This will be chopped to 0x38 == decimal 56

> and register it normally. 
> It is logically impossible to have more than 256
> entries on the cmd list, 
> the boundry check you're adding is completely
> useless.

You cannot have more than 256 commands because 0x138 and 0x38 are
treated as the same command. So does 0x238, 0x1138...
It is useless/unneeded if the register ops will always see the chopped
value. Is this so?

cheers,
jamal

