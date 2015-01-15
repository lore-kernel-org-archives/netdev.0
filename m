From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 13/17] i40e: AQ API updates for new commands
Date: Thu, 15 Jan 2015 19:14:19 +0200
Message-ID: <CAJ3xEMiCLBjuUSh1HGhfJU0gqA7J1MHsp0riLU5kk_uwkAdFqg@mail.gmail.com>
References: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1421324368-6860-14-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Kamil Krawczyk <kamil.krawczyk@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:41639 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947AbbAOROT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 12:14:19 -0500
Received: by mail-oi0-f47.google.com with SMTP id z81so13392676oif.6
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 09:14:19 -0800 (PST)
In-Reply-To: <1421324368-6860-14-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2015 at 2:19 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Shannon Nelson <shannon.nelson@intel.com>
>
> Add lldp control commands, add oem ocsd and ocbb commands, and fix up
> NVM config read and write data structs.

Sounds to me like a proofed nightmare for someone doing future
bisection and landing here... we want kernel patches to be made of
basically one logical change, right?
