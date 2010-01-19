From: David Miller <davem@davemloft.net>
Subject: Re: Global IPV6 auto-configuration does not work as expected.
Date: Tue, 19 Jan 2010 12:35:45 -0800 (PST)
Message-ID: <20100119.123545.180263685.davem@davemloft.net>
References: <brian.haley@hp.com>
	<201001192034.o0JKY0OO001470@wind.enjellic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, nhorman@tuxdriver.com, netdev@vger.kernel.org
To: greg@enjellic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41636
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932105Ab0ASUfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 15:35:36 -0500
In-Reply-To: <201001192034.o0JKY0OO001470@wind.enjellic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: greg@enjellic.com
Date: Tue, 19 Jan 2010 14:34:00 -0600

> That would only be effective with a modular implementation of ipv6.
> As I noted above these are completely static kernels.

That's incorrect, you can still set the parameter if ipv6 is
built statically into your kernel.

You can set "module" parameters on the kernel command line by
saying, f.e., "ipv6.autoconf=0"
