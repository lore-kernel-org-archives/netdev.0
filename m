From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: Re: [PATCH] net: dsa/slave: Fix compilation warnings
Date: Tue, 30 Oct 2012 15:15:30 +0530
Message-ID: <CAKohpo=X0ZNSRZHFO==j43Hq0ZheQLmER9X+adsLQErAJT5f2w@mail.gmail.com>
References: <5afab1ebe83e4361f1fd75bbea0c559af195bf02.1351529738.git.viresh.kumar@linaro.org>
	<1351540778.2721.7.camel@bwh-desktop.uk.solarflarecom.com>
	<CAKohponL_3m2KVytiWm8ZHyB5aimk8CzGrqr5J0LMy8MFGodHg@mail.gmail.com>
	<CAKohponOKk5e2Sxyhjw-XvzVxF3tNp66rsnYCwvwHazAPAauKw@mail.gmail.com>
	<508F8779.8070300@linaro.org>
	<CAKohpokmfFSFsADmtOyN9JRCX8aVdNs+tDFhUQuM6sSQ+dFfUA@mail.gmail.com>
	<508F9724.50804@linaro.org>
	<CAKohpon8C5O4U+h3nr=8gaEQ1f-K9pqafw=5jPrhaGup_3re=g@mail.gmail.com>
	<508F9D5C.2020802@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	linaro-dev@lists.linaro.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, patches@linaro.org
To: Daniel Lezcano <daniel.lezcano@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <508F9D5C.2020802@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30 October 2012 14:56, Daniel Lezcano <daniel.lezcano@linaro.org> wrote:
> Well, it is the same here, no ? Except, it is up to the user to disable
> the option.

I didn't wanted to add code like this:

>> +       select NET_DSA_TAG_DSA if (!NET_DSA_TAG_EDSA &&
>> !NET_DSA_TAG_TRAILER)

Why should we select NET_DSA_TAG_DSA by default? What made us
select that?

For this reason, i went to the solution i offered.

Anyway, i just wanted to get rid of the warning. Whatever maintainer
feels is better must be selected.

--
viresh
