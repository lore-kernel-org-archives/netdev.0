From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] seccomp: fix populating a0-a5 syscall args in 32-bit x86 BPF
Date: Tue, 15 Apr 2014 15:52:42 -0700
Message-ID: <CA+55aFy2hDuadQK=09JiEL9wxLD4OLiODiSzhsydwfP9jkFMpQ@mail.gmail.com>
References: <1397502179-15029-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Eric Paris <eparis@redhat.com>,
	James Morris <james.l.morris@oracle.com>,
	Kees Cook <keescook@chromium.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397502179-15029-1-git-send-email-dborkman@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ Sorry for delayed testing, I just came back home and didn't have
access to the affected 32-bit machine on the road ]

On Mon, Apr 14, 2014 at 12:02 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
> Linus reports that on 32-bit x86 Chromium throws the following seccomp
> resp. audit log messages:

Tested, and fixes the problem for me.

Thanks,

              Linus
