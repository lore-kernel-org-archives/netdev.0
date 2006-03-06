From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 0/8] Intel I/O Acceleration Technology (I/OAT)
Date: Mon, 6 Mar 2006 18:44:07 +0100
Message-ID: <200603061844.07439.netdev@axxeo.de>
References: <20060303214036.11908.10499.stgit@gitlost.site> <20060304.134144.122314124.davem@davemloft.net> <20060305014324.GA20026@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, jengelh@linux01.gwdg.de,
	christopher.leech@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751969AbWCFRo2@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060305014324.GA20026@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Sat, Mar 04, 2006 at 01:41:44PM -0800, David S. Miller (davem@davemloft.net) wrote:
> > From: Jan Engelhardt <jengelh@linux01.gwdg.de>
> > Date: Sat, 4 Mar 2006 19:46:22 +0100 (MET)
> > 
> > > Does this buy the normal standard desktop user anything?
> > 
> > Absolutely, it optimizes end-node performance.
> 
> It really depends on how it is used.
> According to investigation made for kevent based FS AIO reading,
> get_user_pages() performange graph looks like sqrt() function

Hmm, so I should resurrect my user page table walker abstraction?

There I would hand each page to a "recording" function, which
can drop the page from the collection or coalesce it in the collector
if your scatter gather implementation allows it.

Regards

Ingo Oeser
