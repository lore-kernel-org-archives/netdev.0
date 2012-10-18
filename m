From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v1] net/core: support runtime PM on net_device
Date: Thu, 18 Oct 2012 10:29:17 +0200
Message-ID: <8762689o9u.fsf@nemi.mork.no>
References: <1350548469-1267-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Oliver Neukum <oneukum@suse.de>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-pm@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:48327 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752602Ab2JRI3f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 04:29:35 -0400
In-Reply-To: <1350548469-1267-1-git-send-email-ming.lei@canonical.com> (Ming
	Lei's message of "Thu, 18 Oct 2012 16:21:08 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ming Lei <ming.lei@canonical.com> writes:

> In ioctl path on net_device, the physical deivce is often
> touched, but the physical device may have been put into runtime
> suspend state already, so cause some utilitis(ifconfig, ethtool,
> ...) to return failure in this situation.

I have to as the stupid questions again, sorry...

Just wondering, isn't that really a driver problem?  The driver will
know whether or not hardware access is required, and should wake up the
device if necessary.  Unless I misunderstand something here, this seems
like papering over driver bugs?


Bj=C3=B8rn
