From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2009-01-12
Date: Mon, 12 Jan 2009 21:23:45 -0800 (PST)
Message-ID: <20090112.212345.259792227.davem@davemloft.net>
References: <20090112201302.GB3786@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44919
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750844AbZAMFXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 00:23:44 -0500
In-Reply-To: <20090112201302.GB3786@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 12 Jan 2009 15:13:02 -0500

> Please let me know if there are problems!

There's something funny in this tree.   In changeset
19f0a391bf9d88307e52557ff3125b24e2519bd4 there is
a removal of arch/arm/mach-integrator/clock.h

I think when you installed that commit something
automatically deleted zero length files it found,
but that's just a guess.

Please fix this up so I can pull from you.

Otherwise all of those changes looked fine.
