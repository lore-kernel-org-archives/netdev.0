From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH] i40e: constify i40e_client_ops structure
Date: Fri, 13 May 2016 21:46:16 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1605132143400.2235@localhost6.localdomain6>
References: <1462104443-30724-1-git-send-email-Julia.Lawall@lip6.fr>  <0c2df9ca-64bd-ac73-9071-f4d619887df8@redhat.com> <1463168405.2612.23.camel@intel.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1052710282-1463168778=:2235"
Cc: Doug Ledford <dledford@redhat.com>,
	Julia Lawall <julia.lawall@lip6.fr>,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Sean Hefty <sean.hefty@intel.com>,
	Tatyana Nikolova <tatyana.e.nikolova@intel.com>,
	Shiraz Saleem <shiraz.saleem@intel.com>,
	Mustafa Ismail <mustafa.ismail@intel.com>,
	Chien Tin Tung <chien.tin.tung@intel.com>,
	Faisal Latif <faisal.latif@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:47951 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932085AbcEMTqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 15:46:20 -0400
In-Reply-To: <1463168405.2612.23.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1052710282-1463168778=:2235
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT



On Fri, 13 May 2016, Jeff Kirsher wrote:

> On Fri, 2016-05-13 at 12:50 -0400, Doug Ledford wrote:
> > On 05/01/2016 08:07 AM, Julia Lawall wrote:
> > > The i40e_client_ops structure is never modified, so declare it as
> > const.
> > > 
> > > Done with the help of Coccinelle.
> > > 
> > > Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> > 
> > Thanks, applied.
> 
> I already have this patch queued up to push through David Miller's net-next 
> tree.
> 
> Julia- please do not shotgun blast several maintainers and several lists,
> it causes confusion on who is *REALLY* going to accept and apply the patch.
> Please use scripts/get_maintainer.pl to get the correct mailing lists and
> maintainers to add to the To: and CC: lines.

I do.  Probably the patch affects files maintained by different people.  
My assumption would be that everyone responsible for the code that is 
affected by the patch would want to see it.  Perhaps there would have been 
a way to separate it, but the const annotations typically have to be 
consistent everywhere.

julia
--8323328-1052710282-1463168778=:2235--
