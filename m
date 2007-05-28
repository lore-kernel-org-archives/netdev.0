From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 in 2.6.18 silently corrupting data, 2.6.22-rc3 link not detected at all
Date: Mon, 28 May 2007 23:34:25 +0200
Message-ID: <20070528213425.GB4494@electric-eye.fr.zoreil.com>
References: <76366b180705281110j472671a1h6ff5ed5fa711c45e@mail.gmail.com> <20070528195422.GA4927@electric-eye.fr.zoreil.com> <76366b180705281406j69d08bbeu77ff18991f161df8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andrew Paprocki <andrew@ishiboo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58708 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761533AbXE1Vfx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 May 2007 17:35:53 -0400
Content-Disposition: inline
In-Reply-To: <76366b180705281406j69d08bbeu77ff18991f161df8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Paprocki <andrew@ishiboo.com> :
[...]
> The align errors in ethtool show up even in the "working" 2.6.18.
> Could this be related to the fact that other hosts on this gigabit
> network run with a 9000 MTU ? I saw that this chipset has a hardware
> limitation and the drivers caps off at 7200..

Assuming you use a real level 2 ethernet switch, the MTU MUST be the same
for each device in the LAN: cap everybody at 7200 bytes.

I raised the issue with an engineer from Realtek once and he did
not seem to worry too much.

-- 
Ueimor
