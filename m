From: Michael Stone <michael@laptop.org>
Subject: Re: setrlimit(RLIMIT_NETWORK) vs. prctl(???)
Date: Tue, 15 Dec 2009 00:33:08 -0500
Message-ID: <20091215053307.GA6837@heat>
References: <a36005b50912122120n4656b97bx6a6d862a57671e6d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: Ulrich Drepper <drepper@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a36005b50912122120n4656b97bx6a6d862a57671e6d@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ulrich Drepper wrote:
> On Sat, Dec 12, 2009 at 21:09, Michael Stone <michael@laptop.org> wrote:
>> That being said, I'm not wedded to the decision. Could you give me some
>> more specific examples of the kinds of changes in low-level userspace code
>> that you're worried about?
> 
> As summarized in the paraphrased comment, it's a pain to deal with
> rlimit extensions.  It's easy enough to do all this using prctl() with
> the same semantics and without forcing any other code to be modified.
> I let others more competent to judge the usefulness.  But using rlimit
> as the interface is just plain wrong.

I still like the rlimit-based interface because I think it gives good intuition
about how to use the facility and about how it ought to be exposed to high-level
parts of userland but it certainly can't hurt to cook up a version based on
prctl() so that we can make a fair comparison of the two. 

I'll see what I can come up with.

Regards,

Michael
