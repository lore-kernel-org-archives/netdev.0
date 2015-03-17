From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH iproute2 v2] route: label externally offloaded routes
Date: Tue, 17 Mar 2015 08:01:54 +0100
Message-ID: <20150317070154.GC2042@nanopsycho.orion>
References: <1426447894-41398-1-git-send-email-sfeldma@gmail.com>
 <20150316131805.GF12614@gospo.home.greyhouse.net>
 <CAE4R7bC7JPPL2ak0e=qUs3YGhdt81tq1v66+4pDy-bFERXnUyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Netdev <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jeff Kirsher <tarbal@gmail.com>,
	John Linville <linville@tuxdriver.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:36045 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144AbbCQHB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 03:01:59 -0400
Received: by wgra20 with SMTP id a20so722201wgr.3
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 00:01:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bC7JPPL2ak0e=qUs3YGhdt81tq1v66+4pDy-bFERXnUyw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 17, 2015 at 05:14:50AM CET, sfeldma@gmail.com wrote:
>On Mon, Mar 16, 2015 at 6:18 AM, Andy Gospodarek
><gospo@cumulusnetworks.com> wrote:
>> On Sun, Mar 15, 2015 at 12:31:34PM -0700, sfeldma@gmail.com wrote:
>>> From: Scott Feldman <sfeldma@gmail.com>
>>>
>>> v2:
>>>
>>> No clear outcome on polling for choices of "external", "offload", "hw", or
>>> "hardware".  Andy's concern about "external" being confusing for users is
>>> valid.  So, I'm making executive decision to use "external_offload" for label,
>>> as suggested by Jiri.
>>
>> This seems like quite a mouthful.  Just make it 'offload' or 'hardware'
>> so the output of 'ip route show' isn't so long that it will frequently
>> be longer than 80 chars.  Being longer than 80 chars is going to be
>> irritating for _many_ users.
>
>Andy, since you have passion on this topic, would you mind taking it
>from here to get consensus, and post an updated patch, if needed?
>
>I was about to suggest a new made-up work like "keroff" and someday
>the new word is added to Websters .  Daddy, what's "keroff"?  Oh son,
>that means "offloaded from kernel to external device".  Ya, actually,
>that's my vote: keroff.

I like it :)

>
>("koff" was my first choice, but apparently that already has a
>not-so-nice meaning).
>
>-scott
