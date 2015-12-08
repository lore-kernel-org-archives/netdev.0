From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 09/15] i40e: use priv flags to control packet split
Date: Wed, 9 Dec 2015 01:33:52 +0200
Message-ID: <CAJ3xEMiqoLa9uKS5pw4ZhkQuE3b+UoVn3OqLHMudgLKH99fA7A@mail.gmail.com>
References: <1449149160-105219-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1449149160-105219-10-git-send-email-jeffrey.t.kirsher@intel.com>
	<CAJ3xEMi7=-LgxapNQM2YX26nxqA9gCceMX95wOEGn-WztsQYbg@mail.gmail.com>
	<CAEuXFEycBrALvFgb3tvcRgHtNzEq7kRk5tHJ8_-K3HEeWeZswQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:36143 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbbLHXdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 18:33:53 -0500
Received: by igcph11 with SMTP id ph11so106719305igc.1
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 15:33:52 -0800 (PST)
In-Reply-To: <CAEuXFEycBrALvFgb3tvcRgHtNzEq7kRk5tHJ8_-K3HEeWeZswQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 9, 2015 at 1:24 AM, Jesse Brandeburg
<jesse.brandeburg@gmail.com> wrote:
> On Sat, Dec 5, 2015 at 1:25 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>> HDS is a generic feature,and even if you think only Intel hardware is
>> the only hardware that supports that, you have multiple drivers..
>> right? why not go the right way of adding new netdev feature and
>> enable/disable it through the conventional ethtool feature on/off
>> directive?
>
> In this case, the return on the investment in the new feature is too
> low, IMO. If your hardware also supports this feature we can discuss
> adding this via ethtool, and I'd be glad to review any patches, and
> implement for Intel devices if necessary.

Wasn't sure to follow on the ROI comment, but anyway, we can renew
this discussion if/when Mellanox and/or more HWs to open that. BTW do
you iSCSI/NFS or alike benchmark of (say) 4KB payload to demo the gain
of the patch? where does your HW does the HDSplit in case of these or
other IP based storage protocols?

Or.

Or.
