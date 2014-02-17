From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] csum_partial_copy_from_user: clean up inconsistencies
 in implementations
Date: Mon, 17 Feb 2014 23:31:12 +0100
Message-ID: <53028DB0.6000501@redhat.com>
References: <alpine.LRH.2.02.1402151044010.25662@file01.intranet.prod.int.rdu2.redhat.com> <20140217.162105.899153264722449005.davem@davemloft.net> <alpine.LRH.2.02.1402171714030.21254@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mcree@orcon.net.nz,
	mattst88@gmail.com, mathieu.desnoyers@efficios.com,
	jay.estabrook@gmail.com
To: Mikulas Patocka <mpatocka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.02.1402171714030.21254@file01.intranet.prod.int.rdu2.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/17/2014 11:20 PM, Mikulas Patocka wrote:
...
>> The proper way to add commentary is to put it after the "---" delimiter
>> at the end of the commit message and before the actual patch.
>
> Interesting - I used "---" as a delimiter between the commentary and the
> git message in the past and some people said that their patch parser can't
> detect "---" and that I should use "From:" line as a delimiter. And now I
> see that your patch parser doesn't detect "From:" and needs "---".

It's simple: Documentation/SubmittingPatches +582  says ...

The "---" marker line serves the essential purpose of marking for patch
handling tools where the changelog message ends.

One good use for the additional comments after the "---" marker is for
a diffstat, to show what files have changed, and the number of
inserted and deleted lines per file.  A diffstat is especially useful
on bigger patches.  Other comments relevant only to the moment or the
maintainer, not suitable for the permanent changelog, should also go
here.  A good example of such comments might be "patch changelogs"
which describe what has changed between the v1 and v2 version of the
patch.

So, between "---" and the diffstat you could have put your comment.
That's what the official document says in that regard. ;)
