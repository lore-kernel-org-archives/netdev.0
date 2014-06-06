From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 3.4] xen-netback: allow changing the MAC address of the
 interface
Date: Fri, 6 Jun 2014 06:56:23 -0700
Message-ID: <20140606135623.GA11781@kroah.com>
References: <1401738380-11102-1-git-send-email-daniel.kiper@oracle.com>
 <20140605.145844.382754247234672637.davem@davemloft.net>
 <20140605231458.GA31114@kroah.com>
 <20140606130417.GL12025@olila.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, stable@vger.kernel.org,
	msw@amazon.com, netdev@vger.kernel.org, xen-devel@lists.xen.org,
	konrad.wilk@oracle.com
To: Daniel Kiper <daniel.kiper@oracle.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140606130417.GL12025@olila.local.net-space.pl>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 06, 2014 at 03:04:17PM +0200, Daniel Kiper wrote:
> On Thu, Jun 05, 2014 at 04:14:58PM -0700, Greg KH wrote:
> > On Thu, Jun 05, 2014 at 02:58:44PM -0700, David Miller wrote:
> > > From: Daniel Kiper <daniel.kiper@oracle.com>
> > > Date: Mon,  2 Jun 2014 21:46:20 +0200
> > >
> > > > From: Matt Wilson <msw@amazon.com>
> > > >
> > > > Sometimes it is useful to be able to change the MAC address of the
> > > > interface for netback devices. For example, when using ebtables it may
> > > > be useful to be able to distinguish traffic from different interfaces
> > > > without depending on the interface name.
> > > >
> > > > Reported-by: Nikita Borzykh <sample.n@gmail.com>
> > > > Reported-by: Paul Harvey <stockingpaul@hotmail.com>
> > > > Cc: netdev@vger.kernel.org
> > > > Cc: xen-devel@lists.xen.org
> > > > Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> > > > Acked-by: Ian Campbell <ian.campbell@citrix.com>
> > > > Signed-off-by: Matt Wilson <msw@amazon.com>
> > > > Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> > > > Signed-off-by: David S. Miller <davem@davemloft.net>
> > > > (cherry picked from commit 4a633a602c26497b8285a202830829d3be007c7b)
> > > >
> > > > Signed-off-by: Daniel Kiper <daniel.kiper@oracle.com>
> > > > Tested-by: Daniel Kiper <daniel.kiper@oracle.com>
> > > > Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> > >
> > > I don't think this is suitable for -stable.
> > >
> > > -stable should be restricted bug fixes for things that either
> > > are extremely serious, or hit a very huge segment of the user
> > > base.
> > >
> > > This issue does not quality for either condition.
> >
> > Yeah, it seems like a new feature to me, I'll drop it from my to-apply
> > queue.
> 
> Yes, in fact it is, however, without it toolstack pollute /var/log/xen/xen-hotplug.log
> with "RTNETLINK answers: Operation not supported" error when every domain is started.
> Additionally, it is simple two liner and it should not break anything (Konrad and
> I did some tests and everything looks OK). I do not mention that from time to time
> we add some features like support for new hardware with just new device ID (e.g.
> USB devices). So that is why I decided to post this patch to stable.

New device ids and quirks to existing drivers are valid stable patches
(see Documentation/stable_kernel_rules.txt), but new features usually
are not.

thanks,

greg k-h
