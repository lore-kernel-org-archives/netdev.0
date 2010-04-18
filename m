From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] gigaset: include cleanup cleanup
Date: Sun, 18 Apr 2010 11:16:46 +0900
Message-ID: <4BCA6B8E.9000408@kernel.org>
References: <20100416220858.A19F540123@xenon.ts.pxnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>,
	Hansjoerg Lipp <hjlipp@web.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100416220858.A19F540123@xenon.ts.pxnet.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 04/17/2010 07:08 AM, Tilman Schmidt wrote:
> Commit 5a0e3ad causes slab.h to be included twice in many of the
> Gigaset driver's source files, first via the common include file
> gigaset.h and then a second time directly. Drop the spares, and
> use the opportunity to clean up a few more similar cases.
> 
> Impact: cleanup, no functional change
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>
> CC: Tejun Heo <tj@kernel.org>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks for the clean up.

> Seeing that the "include cleanup" patch triggering this was accepted
> after the merge window, I have hopes this one will be accepted, too.

Hmm... through which tree should this go through?  I can route it
through percpu but maybe taking the usual isdn patch path would be
better?

Thanks.

-- 
tejun
