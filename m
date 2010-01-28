From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: PROBLEM: reproducible crash KVM+nf_conntrack all recent 2.6
	kernels
Date: Thu, 28 Jan 2010 11:19:07 +0200
Message-ID: <b6fcc0a1001280119t1394d956paa4865c078b52c9f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jonathan@jonmasters.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> RIP: 0010:[<ffffffff813b4115>]  [<ffffffff813b4115>] destroy_conntrack+0x82/0x114

Rebuild kernel with CONFIG_DEBUG_INFO=y.
Double sure conntracking is compiled-in.
Then run

    addr2line -e vmlinux $RIP

it will tell exact line where kernel is oopsing.
