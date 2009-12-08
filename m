From: Chris Rankin <rankincj@yahoo.com>
Subject: Re: [Bugme-new] [Bug 14749] New: Kernel locks up after a few minutes of heavy surfing
Date: Tue, 8 Dec 2009 01:03:15 -0800 (PST)
Message-ID: <335647.4861.qm@web52906.mail.re2.yahoo.com>
References: <4B1DC202.20607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, stable@kernel.org,
	Neil Horman <nhorman@tuxdriver.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52906.mail.re2.yahoo.com ([206.190.49.16]:32820 "HELO
	web52906.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751089AbZLHJDJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2009 04:03:09 -0500
In-Reply-To: <4B1DC202.20607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--- On Tue, 8/12/09, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Its all two years old UDP bugs (I spot another one some
> hours ago), and very rare.

> I am quite suprised it could happen on your machine on
> demand.

Who said anything about "on demand"? It took about 30 minutes to freeze last time; I was starting to think that a complete recompile had fixed it!

For the record: I've only seen that dmesg warning I've reported *once*, and that didn't kill the machine immediately (hence I was able to report it in the first place).

> 1) Do you have another NIC adapter to try ? It might be a
> buggy driver. (Neil Horman found an error on Intel drivers some
> hours ago, that can corrupt skbs)

I can test any patches for a e1000 that apply to 2.6.31.x. But the e1000 is an on-board device and I don't have another. But Fedora's 2.6.31.x kernels seem OK.

> 2) Could you add following debugging aid ?

Not a problem; I do have a serial console attached.

> 3) Any chance you can do a git bisect ?

How do you git-bisect a bug that you can't reproduce on demand? A negative is easy to spot, but a positive would be not experiencing a random freeze. As I said, I *almost* thought that I'd resolved the issue by recompiling last night.

Cheers,
Chris



      
