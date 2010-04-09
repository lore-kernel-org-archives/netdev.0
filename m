From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1] add ethtool loopback support
Date: Fri, 09 Apr 2010 13:01:38 -0400
Message-ID: <4BBF5D72.8010603@garzik.org>
References: <pvmbpdtn8yh.fsf@chavey.mtv.corp.google.com> <1270751373.5055.22.camel@achroite.uk.solarflarecom.com> 	<w2i97949e3e1004081217jdeca953dz162c62b61c0e8f72@mail.gmail.com> 	<1270755356.5055.23.camel@achroite.uk.solarflarecom.com> <j2r97949e3e1004081543h6258125dm60083556ff28fa88@mail.gmail.com> 	<4BBE78E2.2000709@garzik.org> <x2o97949e3e1004090943o4b6b29e5pd261e2cb4c7f421d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, davem@davemloft.net,
	netdev@vger.kernel.org, therbert@google.com
To: Laurent Chavey <chavey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:22083 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487Ab0DIRBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 13:01:42 -0400
Received: by qw-out-2122.google.com with SMTP id 8so1269224qwh.37
        for <netdev@vger.kernel.org>; Fri, 09 Apr 2010 10:01:41 -0700 (PDT)
In-Reply-To: <x2o97949e3e1004090943o4b6b29e5pd261e2cb4c7f421d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/2010 12:43 PM, Laurent Chavey wrote:
> isn't the existing ETHTOOL_TEST ioctl use for something like self test ?
>
> the intent of this patch is to enable a mode whereby one could run
> netperf / iperf and other application  and have the packets sent and
> received by the driver.

I said "ethtool flags interface", which is ETHTOOL_[GS]FLAGS.

ethtool private flags interface would also work, ETHTOOL_[GS]PFLAGS.

Both are interfaces enabling user setting/clearing of 32 on/off switches 
(bits).

	Jeff




