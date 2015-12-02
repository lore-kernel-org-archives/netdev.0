From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 4/6] mlxsw: core: Implement temperature hwmon
 interface
Date: Wed, 2 Dec 2015 23:35:31 +0100
Message-ID: <20151202223531.GQ2355@nanopsycho.orion>
References: <20151129104918.GC2194@nanopsycho.orion>
 <CAJ3xEMhGv9nTq+CtpX=e4E+4WpipVnc---EUOEqxJ06xOSBsog@mail.gmail.com>
 <20151202222551.GP2355@nanopsycho.orion>
 <20151202.172847.1855287186918935450.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gerlitz.or@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:37734 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbbLBWfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 17:35:34 -0500
Received: by wmww144 with SMTP id w144so77036260wmw.0
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 14:35:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20151202.172847.1855287186918935450.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 02, 2015 at 11:28:47PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Wed, 2 Dec 2015 23:25:52 +0100
>
>> Again, there is no possible way to achieve this bugon, other than a
>> stack corruption. I don't think we should try to cope with a stack
>> corruption.
>
>Then remove the assertion.

I thought that in cases like this it is better to just assert and tell
user that something went horribly and non-recoverably wrong.

Why to continue to work if we know that we are making things wrong
(incorrect structure initialization in this case) ? What am I missing?
