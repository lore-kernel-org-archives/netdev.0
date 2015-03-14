From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v2 net-next 1/2] bpf: allow extended BPF programs access
 skb fields
Date: Fri, 13 Mar 2015 19:27:41 -0700
Message-ID: <55039C9D.6010602@plumgrid.com>
References: <1426273064-4837-1-git-send-email-ast@plumgrid.com> <1426273064-4837-2-git-send-email-ast@plumgrid.com> <550392F7.9040308@iogearbox.net> <550397B0.5070409@iogearbox.net> <5503981C.6000801@plumgrid.com> <55039A0D.20000@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <55039A0D.20000-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 3/13/15 7:16 PM, Daniel Borkmann wrote:
> On 03/14/2015 03:08 AM, Alexei Starovoitov wrote:
>> On 3/13/15 7:06 PM, Daniel Borkmann wrote:
>>> On 03/14/2015 02:46 AM, Daniel Borkmann wrote:
>>> ...
>>>> Previously, it was much more consistent, which I like better. And only
>>>> because of the simple BUILD_BUG_ON()? :/
>>>
>>> Alternative is to move all of them into a central place, something like
>>> in twsk_build_assert() or __mld2_query_bugs[].
>>
>> nope. that defeats the purpose of bug_on.
>
> Well, it doesn't. ;) It throws a build error thus the user is forced to
> investigate that further.

according to this distorted logic all build_bug_on can be in one file
across the whole tree, since 'user is forced to investigate' ?!
