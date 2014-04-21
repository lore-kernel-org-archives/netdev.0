From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net 0/7][pull request] Intel Wired LAN Driver Updates
Date: Mon, 21 Apr 2014 13:24:44 -0700
Message-ID: <1398111884.29946.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1397872767-4001-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20140421.125858.1669714683420708606.davem@davemloft.net>
	 <CAJZOPZLpgT41yfjUDD_8qoOCLWsEAT-XfywaKh_KTTFOMqEdRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:62372 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbaDUUYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 16:24:46 -0400
Received: by mail-pd0-f175.google.com with SMTP id x10so4026075pdj.20
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 13:24:46 -0700 (PDT)
In-Reply-To: <CAJZOPZLpgT41yfjUDD_8qoOCLWsEAT-XfywaKh_KTTFOMqEdRA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-04-21 at 23:15 +0300, Or Gerlitz wrote:
> > From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date: Fri, 18 Apr 2014 18:59:20 -0700
> >> Jesse's i40e patch fixes an issue reported by Eric Dumazet that the
> >> i40e driver was allowing the hardware to replicate the PSH flag on
> >> all segments of a TSO operation.  With this fix, we are now configuring
> >> the CWR bit to only be set in the first packet of a TSO and we
> >> enable TSO_ECN in order to advertise to the stack that we do the right
> >> thing on the wire.
> 
> Hi Jeff, was this report sent over netdev? pointer will be great

Nope, this was a private communication I had with Jesse.
