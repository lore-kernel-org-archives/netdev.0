From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Bug: alx: Atheros AR8131/AR8151/AR8152/AR8161 Ethernet driver
Date: Mon, 5 Aug 2013 22:57:52 -0700
Message-ID: <20130805225752.14e843f7@nehalam.linuxnetplumber.net>
References: <CACtZaFJZCWigdT6_vsP9BTRSORzumu33xUtyPtpiDuNn3DQi+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kinley Dorji <kinleyd@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:50028 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753036Ab3HFF5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 01:57:55 -0400
Received: by mail-pb0-f50.google.com with SMTP id uo5so4330240pbc.9
        for <netdev@vger.kernel.org>; Mon, 05 Aug 2013 22:57:55 -0700 (PDT)
In-Reply-To: <CACtZaFJZCWigdT6_vsP9BTRSORzumu33xUtyPtpiDuNn3DQi+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 Aug 2013 11:31:39 +0600
Kinley Dorji <kinleyd@gmail.com> wrote:

> Hi,
> 
> I'd like to report a bug that has been introduced since the mainlining
> of the NIC drivers originally in the package AUR/dkms-alx pertaining
> to the above mentioned network cards.
> 
> Kernels affected: 3.10.1 - 3.10.5
> All worked well for kernels <= 3.9.9
> 
> Environment in which it occurs:
> 
> kernel: >= 3.10
> conky: any version (gui/cli)
> NIC: Any one of the above family
> 
> conky variables that probe the NIC all return nothing or 0: eg:
> upspeed, upspeedgraph, downspeed, downspeedgraph
> 
> A small discussion on the issue:
> https://bbs.archlinux.org/viewtopic.php?id=166555
> 
> Network connectivity itself is not a problem - connection works and is stable
> 
> Conky isn't the problem because it works in kernels <= 3.9.9 with dkms-alx.
> 

What is conky using to read the variables. Perhaps looking at
CLI tools like:
  ip -s -d li show dev eth0
or
  ethtool -S eth0

would give some indication of which variables are not being incremented.
