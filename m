From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [patch 2/4] mISDN: add support for group membership check
Date: Fri, 20 Sep 2013 18:30:06 +0200
Message-ID: <523C780E.5050201@suse.cz>
References: <523C7464.3070007@suse.cz>	<20130920.121535.1653382964468102292.davem@davemloft.net>	<523C753A.8040401@suse.cz> <20130920.122142.1032350399957506112.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, akpm@linux-foundation.org, jeffm@suse.com,
	netdev@vger.kernel.org, isdn4linux@koppen.de, isdn@linux-pingi.de,
	sergei.shtylyov@cogentembedded.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:38873 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752210Ab3ITQaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 12:30:10 -0400
Received: by mail-ee0-f41.google.com with SMTP id d17so388922eek.0
        for <netdev@vger.kernel.org>; Fri, 20 Sep 2013 09:30:08 -0700 (PDT)
In-Reply-To: <20130920.122142.1032350399957506112.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/2013 06:21 PM, David Miller wrote:
> From: Jiri Slaby <jslaby@suse.cz>
> Date: Fri, 20 Sep 2013 18:18:02 +0200
> 
>> Ok, let's leave the hole in there then.
> 
> Jiri, don't turn this on me.
> 
> The issue is not whether something needs to be fixed or not, I never
> said "don't fix this" and therefore I'd like to ask politely that you
> not make it seem like I have.
> 
> Rather, I'm saying that the implementation is terrible, sets a bad
> precendence for fixing similar problems, and therefore not is in
> a state where we can apply it.
> 
> So, I'm not saying "don't fix this", I'm saying "fix it properly."

Yeah, I understand your point and agree, that the parameter is ugly as
hell. But investing any more time in ISDN is not worth it, I think.
Look, I sent the patch a couple times to the ISDN maintainers and they
didn't even bother to reply. And I am not familiar with the code and do
not want to spend more time than putting there a single check, sorry.
Hence, if there is anybody from the ISDN fellows to take care of that,
nice. If not, we will just live with this patch locally some more years
and drop it when the ISDN subsystem is dropped from the kernel, if
dropped at all.

thanks,
-- 
js
suse labs
