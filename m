From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: fec: warning found by dma debug
Date: Fri, 16 Jan 2015 11:51:01 +0000
Message-ID: <20150116115101.GI12302@n2100.arm.linux.org.uk>
References: <CAH9NwWdR4mPz6c1Ce8tntWFMZXgO20Sgys8pvZwoGhjn6b7fnw@mail.gmail.com>
 <CAOMZO5Cj-b294AkybmU_n6Xfs5+QaVQ1=QkObM-oyUU8Zky19A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christian Gmeiner <christian.gmeiner@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fugang.duan@freescale.com" <fugang.duan@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAOMZO5Cj-b294AkybmU_n6Xfs5+QaVQ1=QkObM-oyUU8Zky19A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 16, 2015 at 09:32:20AM -0200, Fabio Estevam wrote:
> Thanks for the report, Christian
> 
> Adding Andy and Russell on Cc.

Yes, this is highly possible.  My patch set which addressed all sorts
of issues like this is now a year old, and I gave up with trying to
get it merged - it became far too difficult to constantly update the
patch set.

I think Marek was going to look at taking over the patch set, but I've
heard nothing from him.  The patch set can be found at:

  git://ftp.arm.linux.org.uk/~rmk/linux-arm.git fec-testing

but beware: not all of it is meant to be merged.  That branch represents
all patches I tried to solve various problems and improve performance
and correctness (from the ARM architecture point of view).  I did a lot
of work to evaluate the effect of each individual patch, and tried to
only include patches which did not cause a regression.  From what I
remember, every patch (apart from the branch head) from 7e291d514886
(net:fec: unsorted hacks) onwards was not well proven - but that was
all done before the driver ended up with TSO support.

Post TSO support, patches with "net: fec:" (note the space) /were/ good
to go, but then the multiple-queue support got merged which completely
screwed the patch set again.

So, I just totally gave up.  Sorry.

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.
