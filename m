From: jamal <hadi@cyberus.ca>
Subject: Re: [G[PATCH 1/2][ENETLINK] max cmd boundary chec
Date: Fri, 01 Dec 2006 10:54:08 -0500
Message-ID: <1164988448.3550.4.camel@localhost>
References: <1164972613.3562.7.camel@localhost>
	 <20061201124903.GE8693@postel.suug.ch> <1164983427.3562.36.camel@localhost>
	 <20061201144058.GG8693@postel.suug.ch> <1164984758.3562.57.camel@localhost>
	 <20061201151657.GH8693@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.237]:33594 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S967578AbWLAPyM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 10:54:12 -0500
Received: by nz-out-0102.google.com with SMTP id s1so1560457nze
        for <netdev@vger.kernel.org>; Fri, 01 Dec 2006 07:54:12 -0800 (PST)
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061201151657.GH8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-01-12 at 16:16 +0100, Thomas Graf wrote:

> The interface enforces a proper value by the type it accepts which
> is certainly more desireable than a runtime error. 
> If you happen
> to ignore compiler warnings, then maybe there is the problem. 

It is easy to overlook compiler warnings. However, it is not an
excuse. 

> Despite
> of all this, the patch you propose doesn't work anyway.
> 
> If you really want a runtime error you have to change the cmd field
> in genl_ops to be of larger size and then just check > MAX_ARGS in
> register_ops() rather than making get_cmd() more expensive which
> is called for every message received. I don't see any reason why
> this should be better than a compile warning.


Ok, you make a good arguement. Lets just junk this patch. 

cheers,
jamal

