From: "Tim Durack" <tdurack@gmail.com>
Subject: Re: r8169 ethernet bonding problems
Date: Tue, 1 May 2007 16:17:44 -0400
Message-ID: <9e246b4d0705011317t72bc9413u2b002b71ca3865e9@mail.gmail.com>
References: <9e246b4d0704180552q16b05017wd0d7041c3ce04f46@mail.gmail.com>
	 <20070418181333.GA2261@electric-eye.fr.zoreil.com>
	 <9e246b4d0704271353g105ecd62j4f35a6e9027ad590@mail.gmail.com>
	 <20070427220918.GB24358@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.238]:56978 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753639AbXEAURp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 16:17:45 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1924801wxd
        for <netdev@vger.kernel.org>; Tue, 01 May 2007 13:17:45 -0700 (PDT)
In-Reply-To: <20070427220918.GB24358@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> A tcpdump trace 1) before promiscuous mode 2) after promiscuous mode 3)
> after link failure (i.e. failover does not work) would be welcome.

Okay, after fixing STP forwarding delays on the switch, bonding
failover now works, as long as member links are forced to promisc
mode.

Still Have a problem with links randomly failing to achieve link on
boot. This then requires a "modprobe -r r8169; modprobe r8169" cycle
to get link. Side effect is the mac address corruption I have
described previously.

Tim:>
