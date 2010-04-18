From: Karsten Keil <isdn@linux-pingi.de>
Subject: Re: [PATCH] gigaset: include cleanup cleanup
Date: Sun, 18 Apr 2010 15:31:14 +0200
Message-ID: <201004181531.14871.isdn@linux-pingi.de>
References: <20100416220858.A19F540123@xenon.ts.pxnet.com> <4BCA6B8E.9000408@kernel.org>
Reply-To: isdn@linux-pingi.de
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Tilman Schmidt <tilman@imap.cc>,
	David Miller <davem@davemloft.net>,
	Hansjoerg Lipp <hjlipp@web.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BCA6B8E.9000408@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sonntag, 18. April 2010 04:16:46 Tejun Heo wrote:
> Hello,
> 
> On 04/17/2010 07:08 AM, Tilman Schmidt wrote:
> > Commit 5a0e3ad causes slab.h to be included twice in many of the
> > Gigaset driver's source files, first via the common include file
> > gigaset.h and then a second time directly. Drop the spares, and
> > use the opportunity to clean up a few more similar cases.
> >
> > Impact: cleanup, no functional change
> > Signed-off-by: Tilman Schmidt <tilman@imap.cc>
> > CC: Tejun Heo <tj@kernel.org>
> 
> Acked-by: Tejun Heo <tj@kernel.org>
Acked-by: Karsten Keil <isdn@linux-pingi.de>

> 
> Thanks for the clean up.
> 
> > Seeing that the "include cleanup" patch triggering this was accepted
> > after the merge window, I have hopes this one will be accepted, too.
> 
> Hmm... through which tree should this go through?  I can route it
> through percpu but maybe taking the usual isdn patch path would be
> better?
> 
I think David Miller will take it.

Karsten
