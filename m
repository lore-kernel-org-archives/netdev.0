From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: add DiffServ priority based routing
Date: Tue, 12 Jan 2010 12:16:07 -0800 (PST)
Message-ID: <20100112.121607.39835310.davem@davemloft.net>
References: <201001121432.43301.schmto@hrz.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, philipp_subx@redfish-solutions.com
To: torsten.schmidt@s2006.tu-chemnitz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54103
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753823Ab0ALUP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 15:15:58 -0500
In-Reply-To: <201001121432.43301.schmto@hrz.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


You can't do any of these things you are doing, I've basically been
ignoring all of these crazy diffserv patches, they're nuts!

The TOS socket option has a meaning and behavior defined by the BSD
sockets interface many years ago.  And you cannot and must not change
the behavior of those system calls because applications are written to
the current behavior and you will break them.  Protecting the new
behavior with a kernel config option is a non-starter, it's pointless
because no distribution is going to enable a kernel option that
knowingly breaks applications.

And it is also possible to set the TOS field however you desire using
what the kernel currently provides, we do not preclude proper diffserv
support, the BSD socket interfaces allow that just fine.

And you can also do diffserv by classifying traffic and setting the
TOS field using either the packet scheduler, or even netfilter.

Linux supports diffserv fully and just fine, you just can't see it :-)

Please stop submitting these patches without first having at least a
real discussion and understanding of how this stuff works.

Thanks.
