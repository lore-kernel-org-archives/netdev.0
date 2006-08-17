From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: [RFC][PATCH 0/75] pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 15:09:22 +0200
Message-ID: <6bffcb0e0608170609g3926cad7wd3b4737d869ed794@mail.gmail.com>
References: <20060817042634.0.CrzcY28443.28439.michal@ltg01-fedora.pl>
	 <20060817055814.GA14950@kroah.com> <44E46280.2020109@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Greg KH" <greg@kroah.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:29664 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S932475AbWHQNJX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 09:09:23 -0400
Received: by py-out-1112.google.com with SMTP id z74so1431109pyg
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2006 06:09:22 -0700 (PDT)
To: "Jeff Garzik" <jeff@garzik.org>
In-Reply-To: <44E46280.2020109@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17/08/06, Jeff Garzik <jeff@garzik.org> wrote:
> Greg KH wrote:
> > On Thu, Aug 17, 2006 at 04:26:35AM +0000, Michal Piotrowski wrote:
> >> Hi,
> >>
> >> pci_module_init is obsolete.
> >>
> >> This patch series converts pci_module_init to pci_register_driver.
> >>
> >>
> >> Can I remove this?
> >>
> >> include/linux/pci.h:385
> >> /*
> >>  * pci_module_init is obsolete, this stays here till we fix up all usages of it
> >>  * in the tree.
> >>  */
> >> #define pci_module_init pci_register_driver
> >
> > As repeated numerous times, it's up to the network developers if they
> > will take this or not.
> >
> > I'll hold off on taking this series, please push it through the driver
> > subsystem maintainers.
>
> It's already in subsystem trees, in fact.

Did you mean http://www.kernel.org/git/?p=linux/kernel/git/davem/net-2.6.19.git;a=shortlog
?

The patches are against 2.6.18-rc4-mm1. Unfortunately patches weren't
delivered to netdev (my fault). I'll add To:<actual maintainer> and
resend.

>
> But it is most definitely not 2.6.18-rc material :)

I agree.

>
>         Jeff
>

Regards,
Michal

-- 
Michal K. K. Piotrowski
LTG - Linux Testers Group
(http://www.stardust.webpages.pl/ltg/wiki/)
