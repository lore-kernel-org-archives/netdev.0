From: John Heffner <jheffner@psc.edu>
Subject: Re: bug in tcp?
Date: Tue, 17 Apr 2007 00:30:02 -0400
Message-ID: <46244D4A.2010209@psc.edu>
References: <E1HdZgM-0001n2-F0@highlab.com>	<20070416155038.3bfa5104@freekitty>	<E1HdaGU-0001sZ-JS@highlab.com> <20070416163031.6b87764c@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sebastian Kuzminsky <seb@highlab.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:61851 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031081AbXDQEay (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2007 00:30:54 -0400
In-Reply-To: <20070416163031.6b87764c@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> A guess: maybe something related to a PAWS wraparound problem.
> Does turning off sysctl net.ipv4.tcp_timestamps fix it?

That was my first thought too (aside from netfilter), but a failed PAWS 
check should not result in a reset..

   -John
