From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: RFC: another approach for 64-bit network stats
Date: Mon, 7 Jul 2003 10:30:11 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030707143011.GA14787@gtf.org>
References: <3F097E4D.1080707@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <3F097E4D.1080707@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

If you don't want to poll periodically for network stats, as has
been repeatedly suggested, you can always poll periodically for the
64-bit NIC-specific stats that most gige adapters provide these days,
using ethtool.  NIC-specific stats also tend to provide more fine
granularity than the current net_device_stats members.

	Jeff
