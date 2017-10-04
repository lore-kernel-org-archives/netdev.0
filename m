From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH iproute2 2/3] include: add <linux/vm_sockets_diag.h>
Date: Wed, 4 Oct 2017 11:03:50 -0400
Message-ID: <20171004150350.GB3840@stefanha-x1.localdomain>
References: <20171003175744.24987-1-stefanha@redhat.com>
 <20171003175744.24987-3-stefanha@redhat.com>
 <20171003112455.5ebac674@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jorgen Hansen <jhansen@vmware.com>,
        Dexuan Cui <decui@microsoft.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44069 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752403AbdJDPD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Oct 2017 11:03:56 -0400
Content-Disposition: inline
In-Reply-To: <20171003112455.5ebac674@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 03, 2017 at 11:24:55AM -0700, Stephen Hemminger wrote:
> On Tue,  3 Oct 2017 13:57:43 -0400
> Stefan Hajnoczi <stefanha@redhat.com> wrote:
> 
> > This new Linux header file defines the sock_diag interface used by
> > AF_VSOCK.
> > 
> > Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> > ---
> >  include/linux/vm_sockets_diag.h | 33 +++++++++++++++++++++++++++++++++
> >  1 file changed, 33 insertions(+)
> >  create mode 100644 include/linux/vm_sockets_diag.h
> > 
> 
> All header files in linux must be headers that come from 'make install_headers'
> in kernel. I don't see vm_sockets_diag.h even in net-next.

This series depends on "[PATCH 0/5] VSOCK: add sock_diag interface".
Once that has been merged in Linux the <linux/vm_sockets_diag.h> header
will be available.

I sent the ss(8) patch at the same time and referenced the Linux patch
series in the cover letter so they can be reviewed/tested together.

Thanks,
Stefan
