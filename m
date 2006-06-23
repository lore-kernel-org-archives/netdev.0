From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [RFC] sysfs + configfs on 802.11 wireless drivers
Date: Fri, 23 Jun 2006 10:20:25 -0400
Message-ID: <43e72e890606230720ta1dc2cm6c9871a71f3872f0@mail.gmail.com>
References: <43e72e890606220512h5197d473s5f7da9e734814005@mail.gmail.com>
	 <1151063447.2473.6.camel@localhost.localdomain>
	 <20060623124657.GA3256@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Dan Williams" <dcbw@redhat.com>, netdev@vger.kernel.org,
	"Greg KH" <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:34080 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1750753AbWFWOU0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 10:20:26 -0400
Received: by ug-out-1314.google.com with SMTP id a2so1041972ugf
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2006 07:20:25 -0700 (PDT)
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060623124657.GA3256@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/23/06, John W. Linville <linville@tuxdriver.com> wrote:
> On Fri, Jun 23, 2006 at 07:50:47AM -0400, Dan Williams wrote:
>
> > Our effort is probably better spent elsewhere, especially since many
> > popular userspace tools already handle resume for us just fine.  More
> > useful to have drivers just come back from resume in an initialized
> > state similar to system boot.
>
> I think Dan makes a lot of sense here.  Does anyone disagree?

How would we handle resume() when using WPA, for example? Dan are you
suggesting we just bring up the driver clean and expect userspace to
have handled recovery from anything we were doing? This is important.

Or should we just expect the driver to re-set all settings again and
expect wpa_supplicant to pick up well where it left off? If sysfs will
get cleared after resume then there is no point in using it, but if
its stateful after suspend then this is where I suspected
wpa_supplicant could make use of sysfs. Perhaps there is a better way
-- what I suggested was just an idea while we discussed resume/suspend
in another thread. The reason I started a new thread was I figured
configfs/sysfs could be used for other things as well.

  Luis
