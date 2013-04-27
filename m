From: Xi Wang <xi.wang@gmail.com>
Subject: Re: [PATCH v2 net-next 3/3] ARM: net: bpf_jit_32: support
 BPF_S_ANC_SECCOMP_LD_W instruction
Date: Sat, 27 Apr 2013 14:32:19 -0400
Message-ID: <CAKU6vyathpp4Ky_kcTu_WFenLEdo9Mai4TUE=EWYo9=UuQUMcg@mail.gmail.com>
References: <1367029047-14830-1-git-send-email-xi.wang@gmail.com>
 <1367029047-14830-4-git-send-email-xi.wang@gmail.com> <517B6FC5.7070003@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Will Drewry <wad@chromium.org>,
	Eric Dumazet <edumazet@google.com>,
	Russell King <linux@arm.linux.org.uk>,
	David Laight <david.laight@aculab.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nicolas Schichan <nschichan@freebox.fr>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:60284 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753369Ab3D0Sc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Apr 2013 14:32:59 -0400
In-Reply-To: <517B6FC5.7070003@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 27, 2013 at 2:27 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> Arent't you doing here a similar thing in terms of getting arch as Eric
> criticized (Nicolas' implementation does not use that part btw.)? Also,
> even if it would be possible here, now your 2 JIT implementations differ
> in behaviour. I think this is unintended.

Eric's comment was about x86, where the audit arch could change on the
fly.  For ARM, the audit arch doesn't change---syscall_get_arch()
always returns AUDIT_ARCH_ARM.

> Besides all that, I think I also pointed you to a patch that already made
> it in for ARM, not sure why you keep posting the ARM JIT implementation?

That's why I asked in the other post if you wanted me to rebase
against linux-next or net-next.  The ARM part 3/3 is not needed if
rebased against linux-next with Nicolas's patches.

- xi
