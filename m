From: "L F" <lfabio.linux@gmail.com>
Subject: Re: e1000 driver and samba
Date: Mon, 17 Sep 2007 14:58:23 -0400
Message-ID: <780b6f780709171158h1016b6c2kfbc977b4ea7c715c@mail.gmail.com>
References: <780b6f780709131904j41148fb4p827e87530b15d6e9@mail.gmail.com>
	 <46EAC25B.2060404@intel.com>
	 <780b6f780709141140l1fd586c9p2aa8efe6ed803d38@mail.gmail.com>
	 <46EAF644.1040006@intel.com> <46EC1A00.2000304@katalix.com>
	 <46EC2D5A.7080504@intel.com>
	 <780b6f780709152106q3d7f1042t72126c1be16ed1fd@mail.gmail.com>
	 <46ECB95F.2090100@intel.com>
	 <780b6f780709170942h48df5eb4g5f3d19cdf5ef60de@mail.gmail.com>
	 <46EEB33B.6030305@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "James Chapman" <jchapman@katalix.com>, netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.188]:5668 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756464AbXIQS6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 14:58:24 -0400
Received: by rv-out-0910.google.com with SMTP id k20so1383338rvb
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 11:58:23 -0700 (PDT)
In-Reply-To: <46EEB33B.6030305@intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/17/07, Kok, Auke <auke-jan.h.kok@intel.com> wrote:
> The statistic we were looking at _will_ increase when running in half duplex,
> but if it increases when running in full duplex might indicate a hardware
> failure. Probably you have fixed the issue with the CAT6 cable.
Uhm, 'fixed' may be premature: I restarted the machine and with 22
hours uptime I am getting:
tx_deferred_ok: 36254

> Can you run this new configuration with the old cable? that would eliminate
> the cable (or not)
I most certainly can. This seems to have gotten worse by a factor or
100 or more.. so am I to suspect the new cable?

> A single port failure on a switch can also happen, and samba is definately
> a good test for defective hardware. I cannot rule out anything from the
> information we have gotten yet.
True, but I tried changing the switch ports with little change.
Putting a client on the same switch port yielded no errors on the
client, although unfortunately I don't have ethtool statistics on XP.
The switch, btw, is a fairly generic GS108 from Netgear (there
actually are two).

LF
