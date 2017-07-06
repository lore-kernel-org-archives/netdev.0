From: Greg Rose <gvrose8192@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH 1/2] i40e/i40evf: rename
 vf_offload_flags to vf_cap_flags in struct virtchnl_vf_resource
Date: Thu, 6 Jul 2017 15:24:33 +0100
Message-ID: <CALgkqUpFST=oiS+yAFpkCiRS6JPqVg9R7_+3GMNvWoVnB_zoXg@mail.gmail.com>
References: <20170629131225.9251-1-sassmann@kpanic.de> <20170629131225.9251-2-sassmann@kpanic.de>
 <9BBC4E0CF881AA4299206E2E1412B62650490D08@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Stefan Assmann <sassmann@kpanic.de>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
To: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:33648 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751744AbdGFOYg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 10:24:36 -0400
Received: by mail-lf0-f65.google.com with SMTP id t72so620759lff.0
        for <netdev@vger.kernel.org>; Thu, 06 Jul 2017 07:24:35 -0700 (PDT)
In-Reply-To: <9BBC4E0CF881AA4299206E2E1412B62650490D08@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 5, 2017 at 10:15 PM, Wyborny, Carolyn
<carolyn.wyborny@intel.com> wrote:
>
> > -----Original Message-----
> > From: Intel-wired-lan [mailto:intel-wired-lan-bounces@osuosl.org] On Behalf
> > Of Stefan Assmann
> > Sent: Thursday, June 29, 2017 6:12 AM
> > To: intel-wired-lan@lists.osuosl.org
> > Cc: netdev@vger.kernel.org; davem@davemloft.net; sassmann@kpanic.de
> > Subject: [Intel-wired-lan] [PATCH 1/2] i40e/i40evf: rename vf_offload_flags to
> > vf_cap_flags in struct virtchnl_vf_resource
> >
> > The current name of vf_offload_flags indicates that the bitmap is
> > limited to offload related features. Make this more generic by renaming
> > it to vf_cap_flags, which allows for other capabilities besides
> > offloading to be added.
> >
> > Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
> > ---
>
> Hello Stefan,
>
> Thanks for the patch series, but we believe the vf should be ignorant of its trusted status.

Hi Carolyn,

Might I ask why?

Thanks,

- Greg
