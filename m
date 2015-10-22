From: Prarit Bhargava <prarit@redhat.com>
Subject: Re: [PATCH 9/9] treewide: Remove newlines inside DEFINE_PER_CPU()
 macros
Date: Thu, 22 Oct 2015 08:14:42 -0400
Message-ID: <5628D332.9030304@redhat.com>
References: <1444940195-28272-1-git-send-email-mmarek@suse.com> <1444940195-28272-10-git-send-email-mmarek@suse.com> <5627E73B.9000502@redhat.com> <5627ED0D.20308@suse.com> <5628C913.10800@redhat.com> <5628D148.7000102@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, xen-devel@lists.xenproject.org,
	linux-acpi@vger.kernel.org, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org
To: Michal Marek <mmarek@suse.com>
Return-path: <linux-ia64-owner@vger.kernel.org>
In-Reply-To: <5628D148.7000102@suse.com>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 10/22/2015 08:06 AM, Michal Marek wrote:
> On 2015-10-22 13:31, Prarit Bhargava wrote:
>>
>>
>> On 10/21/2015 03:52 PM, Michal Marek wrote:
>>> Dne 21.10.2015 v 21:27 Prarit Bhargava napsal(a):
>>>> On 10/15/2015 04:16 PM, Michal Marek wrote:
>>>>> Otherwise make tags can't parse them:
>>>>>
>>>>> ctags: Warning: arch/ia64/kernel/smp.c:60: null expansion of name pattern "\1"
>>>>> ctags: Warning: drivers/xen/events/events_2l.c:41: null expansion of name pattern "\1"
>>>>> ctags: Warning: drivers/acpi/processor_idle.c:64: null expansion of name pattern "\1"
>>>>> ctags: Warning: kernel/locking/lockdep.c:153: null expansion of name pattern "\1"
>>>>> ctags: Warning: kernel/workqueue.c:305: null expansion of name pattern "\1"
>>>>> ctags: Warning: kernel/rcu/rcutorture.c:133: null expansion of name pattern "\1"
>>>>> ctags: Warning: kernel/rcu/rcutorture.c:135: null expansion of name pattern "\1"
>>>>> ctags: Warning: net/rds/page.c:45: null expansion of name pattern "\1"
>>>>> ctags: Warning: net/ipv4/syncookies.c:53: null expansion of name pattern "\1"
>>>>> ctags: Warning: net/ipv6/syncookies.c:44: null expansion of name pattern "\1"
>>>>
>>>> I guarantee you're going to end up fixing this issue over and over again as more
>>>> code is added in.
>>>
>>> This is certainly going to happen, but it should be quickly spotted by
>>> anybody running make tags on linux-next. And 10 instances since the
>>> beginning of git is not too many.
>>
>> Not everyone uses 'make tags'.  'make cscope' exists and functions correctly ;)
> 
> cscope works, but unfortunately it cannot be extended to understand the
> preprocessor constructs. But it does not suffer from the problem at
> hand, obviously.
> 
> 
>>> It's not ctags itself parsing the DEFINE_PER_CPU() macro, but a
>>> user-supplied regex specified on commandline. Which can only operate on
>>> single lines.
>>>
>>
>> What's the regex?
> 
> See
> https://lkml.kernel.org/r/1444940195-28272-9-git-send-email-mmarek@suse.com
> 
> It used to require a closing parenthesis, so it would not match the
> multiline macro invocations at all. Now it matches them, but ctags
> correctly warns that the empty string is probably not what we intended
> to match.

It seems wrong to change kernel code, not for a bug, but for a userspace search.

P.

> 
> Michal
> 
