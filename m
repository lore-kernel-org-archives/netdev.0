From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 12/15] userns: Convert drm to use kuid and kgid and struct pid where appropriate
Date: Wed, 12 Sep 2012 19:14:55 -0700
Message-ID: <87ligefz34.fsf@xmission.com>
References: <87lih2h6i4.fsf@xmission.com> <87mx1iecwi.fsf@xmission.com>
	<CAPM=9ty=0=+w8VaFC9QhajUkYwmym_JaWR9sbwmgw5tCKg5nGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>,
	David Airlie <airlied@linux.ie>,
	dri-devel@lists.freedesktop.org
To: Dave Airlie <airlied@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <CAPM=9ty=0=+w8VaFC9QhajUkYwmym_JaWR9sbwmgw5tCKg5nGw@mail.gmail.com>
	(Dave Airlie's message of "Thu, 13 Sep 2012 11:31:36 +1000")
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave Airlie <airlied@gmail.com> writes:

>> Blink Blink this had not been converted to use struct pid ages ago?
>>
>> - On drm open capture the openers kuid and struct pid.
>> - On drm close release the kuid and struct pid
>> - When reporting the uid and pid convert the kuid and struct pid
>>   into values in the appropriate namespace.
>>
>
> Hi Eric,
>
> I'm fine with this seems okay, do you want me to merge it via
> drm-next?

My plan is to merge it via my user namespace tree.  And since you have
responed positively I will add your acked-by.  There are some nice
synergies when I get all of the changes in one tree.

If for some reason you want to carry this in your drm tree we can work
something out.

In this case I expect the change isn't big enough to worry about.

Eric
