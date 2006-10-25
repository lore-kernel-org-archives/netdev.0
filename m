From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [RFC] [PATCH 1/3] adds iso3166-1 support
Date: Wed, 25 Oct 2006 11:05:46 -0400
Message-ID: <43e72e890610250805y41349e10tdd5d4d2c36d84b48@mail.gmail.com>
References: <43e72e890610231545n389d8a6dy89bb476101953234@mail.gmail.com>
	 <1161678617.2840.5.camel@ux156>
	 <43e72e890610240859o39a42658p64d198a2130e3f87@mail.gmail.com>
	 <1161706094.3942.24.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Jiri Benc" <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jean Tourrilhes" <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:55848 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S932451AbWJYPFs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 11:05:48 -0400
Received: by ug-out-1314.google.com with SMTP id 32so118818ugm
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2006 08:05:47 -0700 (PDT)
To: "Johannes Berg" <johannes@sipsolutions.net>
In-Reply-To: <1161706094.3942.24.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/24/06, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Tue, 2006-10-24 at 11:59 -0400, Luis R. Rodriguez wrote:
>
> > also if we index based on alpha3 we get O(1)
> > access to the elements. Will make these changes.
>
> I wouldn't do that, it's bound to make the array size explode because
> there'll be one country starting with A and one starting with Z.

You are right.

> Probably better to do a binary search and make sure (by hand) it's
> sorted.

Will work on it when I get time, thanks.

  Luis
