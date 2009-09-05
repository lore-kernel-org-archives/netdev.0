From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] netlink: silence compiler warning
Date: Sat, 05 Sep 2009 09:52:40 +0200
Message-ID: <4AA218C8.4050800@gmail.com>
References: <4AA1B712.6060900@hp.com>	<1252112881.27694.3.camel@violet>	<4AA1C086.5000607@hp.com> <20090904.203318.112406812.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, marcel@holtmann.org, netdev@vger.kernel.org,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:50629 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354AbZIEHxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2009 03:53:01 -0400
Received: by fg-out-1718.google.com with SMTP id 22so322174fge.1
        for <netdev@vger.kernel.org>; Sat, 05 Sep 2009 00:53:03 -0700 (PDT)
In-Reply-To: <20090904.203318.112406812.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote, On 09/05/2009 05:33 AM:

> From: Brian Haley <brian.haley@hp.com>
> Date: Fri, 04 Sep 2009 21:36:06 -0400
> 
>> Hi Marcel,
>>
>> Marcel Holtmann wrote:
>>> can we please add the err = -E... where it actually is needed and not
>>> stupidly go ahead and silence compiler warnings with err = 0. This has
>>> been posted before.
>> Sorry, I don't remember it being posted before.  If you look at the code
>> though, err is correctly initialized, gcc just can't figure it out.  The
>> choices I see are either what I originally posted, using uninitialized_var(err),
>> or the patch below.  It doesn't matter to me.
> 
> uninitialized_var() would be absolutely wrong here, as then we'd
> return garbage if such a path were actually possible.


If the main "thesis" of the patch is:

> From following the code 'err' is initialized, but set it to zero to
> silence the warning.

"we" should better be sure it "is initialized", so considering: "if such
a path were actually possible" "would be absolutely wrong here"...

Here is a link to the message which proved something else was possible
at some moment in -next (I didn't check the current code yet):

From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] Fix Warnings from net/netlink/genetlink.c
Date: Wed, 12 Aug 2009 13:50:31 +1000

Archived-At: http://permalink.gmane.org/gmane.linux.kernel.next/8786

Jarek P.



