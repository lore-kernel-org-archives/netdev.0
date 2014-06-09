From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net-next 06/13] i40e: implement anti-spoofing for VFs
Date: Mon, 9 Jun 2014 22:49:49 +0300
Message-ID: <CAJZOPZJGZNhX7yPF6MvCjW+EYi-EGJgW1GhFa5CO=myAgJj-1A@mail.gmail.com>
References: <1402303758-1429-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1402303758-1429-7-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Mitch Williams <mitch.a.williams@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:52396 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805AbaFITtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 15:49:50 -0400
Received: by mail-qa0-f52.google.com with SMTP id w8so1390325qac.11
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 12:49:49 -0700 (PDT)
In-Reply-To: <1402303758-1429-7-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 9, 2014 at 11:49 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Mitch Williams <mitch.a.williams@intel.com>
>
> Our hardware supports VF antispoofing for both MAC addresses and VLANs.
> Enable this feature by default for all VFs

What do you expect the HW to do when spoof check is enabled (by
default) but the admin didn't configure a MAC address for the VF
through the PF? that is the VF is allowed to use what ever MAC they
want to?

> and implement the netdev op to control it from the command line.
