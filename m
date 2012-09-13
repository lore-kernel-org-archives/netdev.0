From: Dave Airlie <airlied@gmail.com>
Subject: Re: [REVIEW][PATCH 12/15] userns: Convert drm to use kuid and kgid
 and struct pid where appropriate
Date: Thu, 13 Sep 2012 13:29:59 +1000
Message-ID: <CAPM=9tyF=R7KespXvS6FmU0d4KOcu=NT_Y4zm9gbwvfze64hOw@mail.gmail.com>
References: <87lih2h6i4.fsf@xmission.com>
	<87mx1iecwi.fsf@xmission.com>
	<CAPM=9ty=0=+w8VaFC9QhajUkYwmym_JaWR9sbwmgw5tCKg5nGw@mail.gmail.com>
	<87ligefz34.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>,
	David Airlie <airlied@linux.ie>,
	dri-devel@lists.freedesktop.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:64875 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755137Ab2IMDaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 23:30:01 -0400
In-Reply-To: <87ligefz34.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 13, 2012 at 12:14 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Dave Airlie <airlied@gmail.com> writes:
>
>>> Blink Blink this had not been converted to use struct pid ages ago?
>>>
>>> - On drm open capture the openers kuid and struct pid.
>>> - On drm close release the kuid and struct pid
>>> - When reporting the uid and pid convert the kuid and struct pid
>>>   into values in the appropriate namespace.
>>>
>>
>> Hi Eric,
>>
>> I'm fine with this seems okay, do you want me to merge it via
>> drm-next?
>
> My plan is to merge it via my user namespace tree.  And since you have
> responed positively I will add your acked-by.  There are some nice
> synergies when I get all of the changes in one tree.
>
> If for some reason you want to carry this in your drm tree we can work
> something out.
>
> In this case I expect the change isn't big enough to worry about.

No all fine by me,

for formality sake:
Acked-by: Dave Airlie <airlied@redhat.com>
