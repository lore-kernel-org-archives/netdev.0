From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: Use-after-free in ep_remove_wait_queue
Date: Fri, 06 Nov 2015 15:15:44 +0000
Message-ID: <87ziyrcg67.fsf@doppelsaurus.mobileactivedefense.com>
References: <CACT4Y+b3xsLsKVFCz2M7nqqfXnyuMHEVYtJS2wN4WHLWs9A5ng@mail.gmail.com>
	<20151012120249.GB16370@unicorn.suse.cz>
	<1444652071.27760.156.camel@edumazet-glaptop2.roam.corp.google.com>
	<CACT4Y+Z2H8xPg1Dq0Z=HC3WKm+Uw+ZjK6zOLvxhPwFd4D0CsZw@mail.gmail.com>
	<CACT4Y+Zu7J0n6dU1dSfiW3F9Q0Us3_DBVcD5Pi9NG9LER8MmRg@mail.gmail.com>
	<563CC002.5050307@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Vyukov <dvyukov@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Michal Kubecek <mkubecek@suse.cz>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Howells <dhowells@redhat.com>,
	Paul Moore <paul@paul-moore.com>, salyzyn@android.com,
	sds@tycho.nsa.gov, ying.xue@windriver.com,
	netdev <netdev@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Julien Tinnes <jln@google.com>,
	Kees Cook <keescook@google.com>,
	Mathias Krause <minipli@googlemail.com>
To: Jason Baron <jbaron@akamai.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <563CC002.5050307@akamai.com> (Jason Baron's message of "Fri, 6
	Nov 2015 09:58:10 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jason Baron <jbaron@akamai.com> writes:
> On 11/06/2015 08:06 AM, Dmitry Vyukov wrote:
>> On Mon, Oct 12, 2015 at 2:17 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>> On Mon, Oct 12, 2015 at 2:14 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>>> On Mon, 2015-10-12 at 14:02 +0200, Michal Kubecek wrote:
>>>>
>>>>> Probably the issue discussed in
>>>>>
>>>>>   http://thread.gmane.org/gmane.linux.kernel/2057497/
>>>>>
>>>>> and previous related threads.
>>>>>
>>>>
>>>> Same issue, but Dmitry apparently did not trust me.
>>>
>>> Just wanted to make sure. Let's consider this as fixed.
>> 
>> 
>> Is it meant to be fixed now?
>> 
>> I am still seeing use-after-free reports in ep_unregister_pollwait on
>> d1e41ff11941784f469f17795a4d9425c2eb4b7a (Nov 5).
>> 
>
> Indeed - No formal patch has been posted for this yet - we've agreed
> that Rainer is going to post the patch for this issue.

I should be able to put some more work into this on Sunday or possibly
(but unlikely) later today (supposed to mean that I'll also actually do
that).
