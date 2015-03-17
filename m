From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH iproute2 v2] route: label externally offloaded routes
Date: Mon, 16 Mar 2015 21:14:50 -0700
Message-ID: <CAE4R7bC7JPPL2ak0e=qUs3YGhdt81tq1v66+4pDy-bFERXnUyw@mail.gmail.com>
References: <1426447894-41398-1-git-send-email-sfeldma@gmail.com>
	<20150316131805.GF12614@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jeff Kirsher <tarbal@gmail.com>,
	John Linville <linville@tuxdriver.com>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:36547 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbbCQEOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 00:14:50 -0400
Received: by qcto4 with SMTP id o4so63645723qct.3
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 21:14:50 -0700 (PDT)
In-Reply-To: <20150316131805.GF12614@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 16, 2015 at 6:18 AM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:
> On Sun, Mar 15, 2015 at 12:31:34PM -0700, sfeldma@gmail.com wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> v2:
>>
>> No clear outcome on polling for choices of "external", "offload", "hw", or
>> "hardware".  Andy's concern about "external" being confusing for users is
>> valid.  So, I'm making executive decision to use "external_offload" for label,
>> as suggested by Jiri.
>
> This seems like quite a mouthful.  Just make it 'offload' or 'hardware'
> so the output of 'ip route show' isn't so long that it will frequently
> be longer than 80 chars.  Being longer than 80 chars is going to be
> irritating for _many_ users.

Andy, since you have passion on this topic, would you mind taking it
from here to get consensus, and post an updated patch, if needed?

I was about to suggest a new made-up work like "keroff" and someday
the new word is added to Websters .  Daddy, what's "keroff"?  Oh son,
that means "offloaded from kernel to external device".  Ya, actually,
that's my vote: keroff.

("koff" was my first choice, but apparently that already has a
not-so-nice meaning).

-scott
