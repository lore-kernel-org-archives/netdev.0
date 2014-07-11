From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH for stable 3.10] xen-netback: drop SKB from
 internal queue if frontend is disconnected
Date: Fri, 11 Jul 2014 14:43:59 +0100
Message-ID: <20140711134359.GH12584@zion.uk.xensource.com>
References: <1405084112-8134-1-git-send-email-wei.liu2@citrix.com>
	<1405084529.27875.1.camel@kazak.uk.xensource.com>
	<20140711132831.GG12584@zion.uk.xensource.com>
	<1405085451.27875.5.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Philipp Hahn <hahn@univention.de>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xen.org
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
Content-Disposition: inline
In-Reply-To: <1405085451.27875.5.camel@kazak.uk.xensource.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 11, 2014 at 02:30:51PM +0100, Ian Campbell wrote:
[...]
> > > > This bug only manifests in 3.10 kernel. Kernel >=3.12 doesn't have it.
> > > 
> > > What about 3.11?
> > > 
> > 
> > 3.11 is long dead while 3.10 is LTS kernel. I don't think GregKH accepts
> > patch for 3.11 anymore.
> 
> Whether Greg would take a patch is orthogonal to whether the bug exists
> in 3.11 though. Someone might want to fix their own kernel locally for
> example...
> 

To be clear, 3.11 doesn't have that fix which introduced this bug,
because GregKH explictly rejected that fix as 3.11 was already dead at
that time. So this patch is not applicable to 3.11 (whether 3.11 has
some other bugs is another problem).

See <20131202171958.GA661@kroah.com> and the thread it's in.

Wei.

> Ian.
