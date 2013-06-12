From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: pull request: wireless 2013-06-06
Date: Wed, 12 Jun 2013 08:26:49 +0200
Message-ID: <1371018409.8601.2.camel@jlt4.sipsolutions.net>
References: <20130606190929.GB18827@tuxdriver.com>
	 <20130611.222706.1492583255605214982.davem@davemloft.net>
	 (sfid-20130612_072751_104839_5F29BCA5)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130611.222706.1492583255605214982.davem@davemloft.net> (sfid-20130612_072751_104839_5F29BCA5)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-06-11 at 22:27 -0700, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Thu, 6 Jun 2013 15:09:30 -0400
> 
> > Johannes Berg (2):
> >       mac80211: constify ieee802_11_parse_elems() argument
> 
> Such cleanups are absolutely, positively, not appropriate at this
> time.

My other fix depends on this to not have a const warning. I can add a
cast to pretend the input isn't const at this point, but that seemed
like a bad idea as well.

johannes
