From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/2] ipg: redundancy with mii.h
Date: Sun, 21 May 2006 12:16:20 +0200
Message-ID: <20060521101620.GA28210@electric-eye.fr.zoreil.com>
References: <1146506939.23931.2.camel@localhost> <20060501231206.GD7419@electric-eye.fr.zoreil.com> <Pine.LNX.4.58.0605020945010.4066@sbz-30.cs.Helsinki.FI> <20060502214520.GC26357@electric-eye.fr.zoreil.com> <20060502215559.GA1119@electric-eye.fr.zoreil.com> <Pine.LNX.4.58.0605030913210.6032@sbz-30.cs.Helsinki.FI> <20060503233558.GA27232@electric-eye.fr.zoreil.com> <1146750276.11422.0.camel@localhost> <20060504235549.GA9128@electric-eye.fr.zoreil.com> <446F840E.3020808@cantab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	david@pleyades.net, jesse@icplus.com.tw
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:6299 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751515AbWEUKU2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 May 2006 06:20:28 -0400
To: David Vrabel <dvrabel@cantab.net>
Content-Disposition: inline
In-Reply-To: <446F840E.3020808@cantab.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Vrabel <dvrabel@cantab.net> :
[...]
> 0007-ipg-plug-leaks-in-the-error-path-of-ipg_nic_open.txt broke receive 
> since it was skipping the initialization of the Rx buffers.  Patch attached.

Oops. Applied to branch netdev-ipg of
git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git

(please include the '-p' option in future invocation of diff)

I have put an updated patch against 2.6.17-rc4 for the whole driver at
http://www.fr.zoreil.com/people/francois/misc/20060521-2.6.17-rc4-git-ip1000-test.patch

-- 
Ueimor
