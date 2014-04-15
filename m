From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] seccomp: fix populating a0-a5 syscall args in 32-bit
 x86 BPF
Date: Tue, 15 Apr 2014 19:17:43 -0400 (EDT)
Message-ID: <20140415.191743.963157803966994138.davem@davemloft.net>
References: <1397502179-15029-1-git-send-email-dborkman@redhat.com>
	<CA+55aFy2hDuadQK=09JiEL9wxLD4OLiODiSzhsydwfP9jkFMpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ast@plumgrid.com, eparis@redhat.com,
	james.l.morris@oracle.com, keescook@chromium.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFy2hDuadQK=09JiEL9wxLD4OLiODiSzhsydwfP9jkFMpQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 15 Apr 2014 15:52:42 -0700

> [ Sorry for delayed testing, I just came back home and didn't have
> access to the affected 32-bit machine on the road ]
> 
> On Mon, Apr 14, 2014 at 12:02 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> Linus reports that on 32-bit x86 Chromium throws the following seccomp
>> resp. audit log messages:
> 
> Tested, and fixes the problem for me.

I'll push this fix to you later this evening.
