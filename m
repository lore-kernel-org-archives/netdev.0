From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v2 00/10] userns: sysctl limits for namespaces
Date: Tue, 26 Jul 2016 13:44:21 -0700
Message-ID: <CAGXu5jJiSwjTYpPbCUmKGDUNGvXt4GxML6T0b5sNeT03dvjNrg@mail.gmail.com>
References: <8737n5dscy.fsf@x220.int.ebiederm.org> <87d1m754jc.fsf@x220.int.ebiederm.org>
 <6be70177-a81d-7ed8-d2c9-a596d4d6a165@gmail.com> <87shuwtp4c.fsf@x220.int.ebiederm.org>
 <CAGXu5j+ZtZAFpW0ajnnBTRZk17ez6XYF=meEJY_rF7wwgyZB5Q@mail.gmail.com> <CAKgNAkhCvb-WkBbwebbBw6cfhg0FJ-SSbvK=aS1WK+BQ55eO5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Jann Horn <jann@thejh.net>, Nikolay Borisov <kernel@kyup.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Seth Forshee <seth.forshee@canonical.com>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux API <linux-api@vger.kernel.org>
To: Michael Kerrisk-manpages <mtk.manpages@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <CAKgNAkhCvb-WkBbwebbBw6cfhg0FJ-SSbvK=aS1WK+BQ55eO5Q@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 26, 2016 at 10:29 AM, Michael Kerrisk (man-pages)
<mtk.manpages@gmail.com> wrote:
> On 26 July 2016 at 18:52, Kees Cook <keescook@chromium.org> wrote:
>> On Tue, Jul 26, 2016 at 8:06 AM, Eric W. Biederman
>> <ebiederm@xmission.com> wrote:
>>> "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com> writes:
>>>
>>>> Hello Eric,
>>>>
>>>> I realized I had a question after the last mail.
>>>>
>>>> On 07/21/2016 06:39 PM, Eric W. Biederman wrote:
>>>>>
>>>>> This patchset addresses two use cases:
>>>>> - Implement a sane upper bound on the number of namespaces.
>>>>> - Provide a way for sandboxes to limit the attack surface from
>>>>>   namespaces.
>>>>
>>>> Can you say more about the second point? What exactly is the
>>>> problem that is being addressed, and how does the patch series
>>>> address it? (It would be good to have those details in the
>>>> revised commit message...)
>>>
>>> At some point it was reported that seccomp was not sufficient to disable
>>> namespace creation.  I need to go back and look at that claim to see
>>> which set of circumstances that was referring to.  Seccomp doesn't stack
>>> so I can see why it is an issue.
>>
>> seccomp does stack. The trouble usually comes from a perception that
>> seccomp overhead is not trivial, so setting a system-wide policy is a
>> bit of a large hammer for such a limitiation. Also, at the time,
>> seccomp could be bypasses with ptrace, but this (as of v4.8) is no
>> longer true.
>
> Sounds like someone needs to send me a patch for the seccomp.2 man page?

It's on my TODO list, no worries. :) I'm waiting for it to land in
Linus's tree first. It's only been in -next so far.

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security
