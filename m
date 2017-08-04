From: Roland Dreier <roland@kernel.org>
Subject: Re: [PATCH] PCI: Update ACS quirk for more Intel 10G NICs
Date: Fri, 4 Aug 2017 14:47:10 -0700
Message-ID: <CAG4TOxOt=dtUW8q+G-ZRdF-ik19jp2Luw1K8dxHaH2f6AMTZLA@mail.gmail.com>
References: <20170720214101.7449-1-roland@kernel.org> <20170803214911.GG20308@bhelgaas-glaptop.roam.corp.google.com>
 <20170803161623.31e5fb86@w520.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Bjorn Helgaas <helgaas@kernel.org>,
        Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Emil Tantilov <emil.s.tantilov@intel.com>
To: Alex Williamson <alex.williamson@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:34195 "EHLO
        mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751312AbdHDVrd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 17:47:33 -0400
In-Reply-To: <20170803161623.31e5fb86@w520.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I think the conclusion is that a hard-wired ACS capability is a
> positive indication of isolation for a multifunction device, the code
> is intended to support this and appears to do so, and Roland was going
> to investigate the sightings that inspired this patch in more detail.
> Dropping for now is appropriate.  Thanks,

That's right.  I confirmed that the issue we found was due to another PCI quirk.

It may make sense to add more 82599 variants to the table, but the X540 and X550
work without a quirk.

Sorry for the noise.

 - R.
