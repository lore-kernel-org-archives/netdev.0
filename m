From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 1/2] bpf: allow extended BPF programs access
 skb fields
Date: Sat, 14 Mar 2015 03:16:45 +0100
Message-ID: <55039A0D.20000@iogearbox.net>
References: <1426273064-4837-1-git-send-email-ast@plumgrid.com> <1426273064-4837-2-git-send-email-ast@plumgrid.com> <550392F7.9040308@iogearbox.net> <550397B0.5070409@iogearbox.net> <5503981C.6000801@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5503981C.6000801@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/14/2015 03:08 AM, Alexei Starovoitov wrote:
> On 3/13/15 7:06 PM, Daniel Borkmann wrote:
>> On 03/14/2015 02:46 AM, Daniel Borkmann wrote:
>> ...
>>> Previously, it was much more consistent, which I like better. And only
>>> because of the simple BUILD_BUG_ON()? :/
>>
>> Alternative is to move all of them into a central place, something like
>> in twsk_build_assert() or __mld2_query_bugs[].
>
> nope. that defeats the purpose of bug_on.

Well, it doesn't. ;) It throws a build error thus the user is forced to
investigate that further.
