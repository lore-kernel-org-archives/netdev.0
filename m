From: "Yang, Yi" <yi.y.yang@intel.com>
Subject: Re: [PATCH net-next] openvswitch: fix VxLAN-gpe port can't be
 created in ovs compat mode
Date: Fri, 9 Dec 2016 08:27:39 +0800
Message-ID: <20161209002739.GA26492@cran64.bj.intel.com>
References: <1481185210-13056-1-git-send-email-yi.y.yang@intel.com>
 <CAOrHB_CVr0PQGsNkhrrvT7L8cX1KZypV4UXakXm1uuCz7ZPYHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org, jbenc@redhat.com
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:13254 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752207AbcLIAhY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 19:37:24 -0500
Content-Disposition: inline
In-Reply-To: <CAOrHB_CVr0PQGsNkhrrvT7L8cX1KZypV4UXakXm1uuCz7ZPYHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 08, 2016 at 11:41:58AM -0800, Pravin Shelar wrote:
> On Thu, Dec 8, 2016 at 12:20 AM, Yi Yang <yi.y.yang@intel.com> wrote:
> >
> > Signed-off-by: Yi Yang <yi.y.yang@intel.com>
> > ---
> >  include/uapi/linux/openvswitch.h |  1 +
> >  net/openvswitch/vport-vxlan.c    | 15 +++++++++++++++
> >  2 files changed, 16 insertions(+)
> >
> There is no need for this patch in upstream kernel module. I am open
> to having such a patch in out of tree kernel if it simplifies feature
> compatibility code.

I'm very glad to hear this :-), the goal is to enable current ovs to create
vxlan-gpe port in compat mode without new kernel help, I'll post a patch
for ovs, thanks a lot.
