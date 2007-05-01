From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 ethernet bonding problems
Date: Tue, 1 May 2007 22:47:21 +0200
Message-ID: <20070501204721.GB19212@electric-eye.fr.zoreil.com>
References: <9e246b4d0704180552q16b05017wd0d7041c3ce04f46@mail.gmail.com> <20070418181333.GA2261@electric-eye.fr.zoreil.com> <9e246b4d0704271353g105ecd62j4f35a6e9027ad590@mail.gmail.com> <20070427220918.GB24358@electric-eye.fr.zoreil.com> <9e246b4d0705011317t72bc9413u2b002b71ca3865e9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tim Durack <tdurack@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:33395 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945960AbXEAUuG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 16:50:06 -0400
Content-Disposition: inline
In-Reply-To: <9e246b4d0705011317t72bc9413u2b002b71ca3865e9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tim Durack <tdurack@gmail.com> :
[...]
> Still Have a problem with links randomly failing to achieve link on
> boot. This then requires a "modprobe -r r8169; modprobe r8169" cycle
> to get link. Side effect is the mac address corruption I have
> described previously.

Can you try to set the MAC address by hand with the completely patched
kernel (i.e. including the mac-address-change patch) ?

Given the last report in http://bugzilla.kernel.org/show_bug.cgi?id=6032,
it should be straightforward with your Debian system.

No clear idea why your three cards are not handled the same though.

-- 
Ueimor

Anybody got a battery for my Ultra 10 ?
