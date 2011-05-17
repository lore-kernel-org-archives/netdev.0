From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: sfc: an enumeration is not a bitmask
Date: Tue, 17 May 2011 14:57:03 -0400
Message-ID: <BANLkTi=n_0JiF0Lm=+1OwRzB4XQFBtg8KA@mail.gmail.com>
References: <20110517.141446.140687548350861625.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:34274 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756345Ab1EQS5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 14:57:04 -0400
Received: by gxk21 with SMTP id 21so270285gxk.19
        for <netdev@vger.kernel.org>; Tue, 17 May 2011 11:57:04 -0700 (PDT)
In-Reply-To: <20110517.141446.140687548350861625.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/17 David Miller <davem@davemloft.net>:
> An enumeration is not a bitmask, instead it means one out of the set
> of enumerated values will be used.

It's a decade-old kernel practice to use 'enum' to define typed
constants, preferred over  macros that convey no type information and
disappear after cpp phase.

So your assertion about enumerations is demonstrably not true, as it
is often used in the kernel.  Call it enum abuse if you want, but it
is consistent with code all over the kernel.

That said, I agree that warnings should of course be addressed in some manner.

    Jeff
