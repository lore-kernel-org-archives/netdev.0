From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] tcp: sysctl to disable TCP simultaneous connect
Date: Thu, 14 Feb 2013 23:10:46 -0800
Message-ID: <87r4ki6oi1.fsf@xmission.com>
References: <20130207175240.GA12520@www.outflux.net>
	<20130207103950.662698ea@nehalam.linuxnetplumber.net>
	<CAGXu5jJiupzommJYPEYQnk-4i9FUKai0NcPnihLN-QpWV64jtQ@mail.gmail.com>
	<87y5eq87pa.fsf@xmission.com>
	<CAGXu5jJKQSDo61TD0Jgn9Gq8TL2rCUVbA=Kq4AvfeFUb2FdJMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Rob Landley <rob@landley.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Yuchung Cheng <ycheng@google.com>,
	Shan Wei <davidshan@tencent.com>,
	"linux-doc\@vger.kernel.org" <linux-doc@vger.kernel.org>,
	netdev@vger.kernel.org, Willy Tarreau <w@1wt.eu>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jJKQSDo61TD0Jgn9Gq8TL2rCUVbA=Kq4AvfeFUb2FdJMw@mail.gmail.com>
	(Kees Cook's message of "Thu, 14 Feb 2013 22:41:39 -0800")
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kees Cook <keescook@chromium.org> writes:

> On Thu, Feb 14, 2013 at 9:30 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>> Kees Cook <keescook@chromium.org> writes:
>>
>>> The patch would not break it -- it defaults the sysctl to staying enabled.
>>>
>>> If you mean the documentation should be updated, sure, that's easy to do.
>>>
>>> David: I know you aren't a fan of this patch, but I'd like to try to
>>> convince you. :) This leaves the feature enabled and add a toggle for
>>> systems (like Chrome OS) that don't want to risk this DoS at all.
>>> There are so very many other toggle, I don't see why this one would be
>>> a problem to add.
>>
>> Chrome OS has no plans to implement webrtc?  Last I had read that
>> support had been added to the release versions of Chrome, and was in the
>> development builds of firefox.  I really don't belive that there are
>> many systems that don't intend to run a web browser.
>
> I haven't looked at the internals of webrtc. Are you implying some
> feature in it relies on the TCP simultaneous connect?

I am saying that yes.

webrtc is built on ICE (interactivity connectivity establishment).  ICE
support for TCP (RFC6544) uses TCP simultaneous connect.  webrtc
supports tcp connections.

Eric

