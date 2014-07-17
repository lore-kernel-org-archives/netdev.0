From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Wed, 16 Jul 2014 17:05:12 -1000
Message-ID: <CA+55aFzbpYjoJfLnoQy_rGb-FYoh5LKVeTRhp7xX_vXEFk_adA@mail.gmail.com>
References: <20140715.002844.679028486034873225.davem@davemloft.net>
	<CA+55aFw9=c_jSb7GOXDoityxWGiDs9y7LsdasyPHXESiZR75bg@mail.gmail.com>
	<20140715.114614.827795344549781033.davem@davemloft.net>
	<20140715190252.GC26012@tuxdriver.com>
	<877g3cbueb.fsf@purkki.adurom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Kalle Valo <kvalo@adurom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <877g3cbueb.fsf@purkki.adurom.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 16, 2014 at 4:18 PM, Kalle Valo <kvalo@adurom.com> wrote:
>
> Just out of curiosity, what is the best way to send a proposal how to
> fix a merge conflict? For example, if I send a pull request to John
> which I know will issue a conflict it would be nice to include
> instructions (or some sort of patch) how I think it should be resolved.

So from personal experience seeing lots of different explanations, my
preferred one is not so much a patch, as explaining *why* something
generates a merge conflict.

Optimally for each conflict, say what happened ("X changed Y, A
changed B close by") and then describe the result in those terms (eg
"pick the code from my branch, but then do the rename of xyz to abc
that caused the conflict", or "pick your side, it obsoletes the fix
from me that causes the conflict" or whatever).

And if you have a *lot* of conflicts, explain why that happaned too,
and think very hard about whether what you do is perhaps screwed up
(or complain about the other entity that did annoying whitespace
changes for no good reason or whatever). Maybe it's just that the
source code is badly organized, but more likely it's because somebody
is just doing something stupid, and people are stepping on each others
toes. If the explanation is "this is a one-time issue brought on by
xyz", then that's fine - sh*t happens. If it's something else, at
least mention it. And if it keeps happening, something needs to be
done.

And in the end, I personally tend to always resolve the conflicts
*without* really looking at the explanation, by just trying to figure
it out on my own. I've had people send me incorrect resolution
suggestions, and I've also occasionally just screwed up my own
resolution. Having somebody elses explanations of what they did is a
good sanity check that things went right (when their explanation
matches mine), and is a good red flag about "maybe this is more
complicated than I thought" when the explanations and results don't
match up.

                     Linus
