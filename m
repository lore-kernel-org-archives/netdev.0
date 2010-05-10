From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: bluetooth-next-2.6 2010-05-10
Date: Mon, 10 May 2010 04:32:13 -0700 (PDT)
Message-ID: <20100510.043213.190395121.davem@davemloft.net>
References: <cover.1273484094.git.marcel@holtmann.org>
	<20100510.042031.135962157.davem@davemloft.net>
	<20100510.042829.93442711.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53934
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755333Ab0EJLcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 07:32:09 -0400
In-Reply-To: <20100510.042829.93442711.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


BT_L2CAP_EXT_FEATURES makes no sense at all...

If someone can rebuild their kernel, they can just as equally add
an entry to /etc/sysctl.conf to turn that thing on early in the
boot process.

It's not like you're going to get distributions to enable this kernel
config option by default to get "wider coverage" for testing this new
feature.

Please just toss this thing, and please don't post so much of this
kind of stuff in one go ever again, this way problems like this and
the other one's can be caught early, rather than my having to pick
apart several problematic changes in one huge pass. :-/

Thanks.
