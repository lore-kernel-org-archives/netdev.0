From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v9 net-next 4/7] openvswitch: add layer 3 flow/port
 support
Date: Fri, 20 May 2016 10:00:28 +0200
Message-ID: <20160520100028.0065a2ef@griffin>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
	<1462347393-22354-5-git-send-email-simon.horman@netronome.com>
	<20160517163250.7ead555e@griffin>
	<20160520052858.GA15505@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Lorand Jakab <lojakab@cisco.com>,
	Thomas Morin <thomas.morin@orange.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47775 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754586AbcETIAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 May 2016 04:00:34 -0400
In-Reply-To: <20160520052858.GA15505@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 May 2016 14:29:01 +0900, Simon Horman wrote:
> The second option does seem rather tempting although I'm not sure
> that it actually plays out in the access-port scenario at this time.

We support gre ports to be access ports currently. With conversion to
ipgre, this needs to continue working. It's no problem for frames with
the Ethernet header but now we have a situation where a port is tagged,
thus the user expects that packets received on that port will behave
accordingly. I don't think we can make some packets honor this and some
ignore this; and we can't disallow gre to be an access port.

How do you plan to solve this? By user space always pushing an ethernet
header before push_vlan?

 Jiri
