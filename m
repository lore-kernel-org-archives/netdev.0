From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCHv7] add mergeable buffers support to vhost_net
Date: Mon, 3 May 2010 09:19:41 -0700
Message-ID: <OF065832F6.4C8FA06E-ON88257718.00592675-88257718.0059B163@us.ibm.com>
References: <20100503155613.GB12449@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.osdl.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:46549 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933114Ab0ECQUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 12:20:04 -0400
In-Reply-To: <20100503155613.GB12449@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael S. Tsirkin" <mst@redhat.com> wrote on 05/03/2010 08:56:14 AM:

> On Mon, May 03, 2010 at 08:39:08AM -0700, David Stevens wrote:
> > "Michael S. Tsirkin" <mst@redhat.com> wrote on 05/03/2010 03:34:11 AM:
> > 
> > > On Wed, Apr 28, 2010 at 01:57:12PM -0700, David L Stevens wrote:
> > > > This patch adds mergeable receive buffer support to vhost_net.
> > > > 
> > > > Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
> > > 
> > > I've been doing some more testing before sending out a pull
> > > request, and I see a drastic performance degradation in guest to 
host
> > > traffic when this is applied but mergeable buffers are not in used
> > > by userspace (existing qemu-kvm userspace).
> > 
> >         Actually, I wouldn't expect it to work at all;
> > the qemu-kvm
> > patch (particularly the feature bit setting bug fix) is required.
> 
> Which bugfix is that?

        Actually, I see you put that upstream already--
commit dc14a397812b91dd0d48b03d1b8f66a251542369  in
Avi's tree is the one I was talking about.
        I'll look further.

                                                +-DLS

