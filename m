From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: [net-next 09/15] i40e: use priv flags to control packet split
Date: Tue, 8 Dec 2015 15:24:47 -0800
Message-ID: <CAEuXFEycBrALvFgb3tvcRgHtNzEq7kRk5tHJ8_-K3HEeWeZswQ@mail.gmail.com>
References: <1449149160-105219-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1449149160-105219-10-git-send-email-jeffrey.t.kirsher@intel.com>
	<CAJ3xEMi7=-LgxapNQM2YX26nxqA9gCceMX95wOEGn-WztsQYbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:36789 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871AbbLHXYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 18:24:48 -0500
Received: by iofh3 with SMTP id h3so41224209iof.3
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 15:24:48 -0800 (PST)
In-Reply-To: <CAJ3xEMi7=-LgxapNQM2YX26nxqA9gCceMX95wOEGn-WztsQYbg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 5, 2015 at 1:25 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> HDS is a generic feature,and even if you think only Intel hardware is
> the only hardware that supports that, you have multiple drivers..
> right? why not go the right way of adding new netdev feature and
> enable/disable it through the conventional ethtool feature on/off
> directive?

In this case, the return on the investment in the new feature is too
low, IMO. If your hardware also supports this feature we can discuss
adding this via ethtool, and I'd be glad to review any patches, and
implement for Intel devices if necessary.
