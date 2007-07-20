From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Linux, tcpdump and vlan
Date: Fri, 20 Jul 2007 22:19:45 +0200
Message-ID: <m3r6n2zv32.fsf@maximus.localdomain>
References: <930446.33248.qm@web56601.mail.re3.yahoo.com>
	<469FF611.6080905@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andrei radulescu-banu <iubica2@yahoo.com>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:55192 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752715AbXGTUTr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2007 16:19:47 -0400
In-Reply-To: <469FF611.6080905@candelatech.com> (Ben Greear's message of "Thu, 19 Jul 2007 16:38:57 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear <greearb@candelatech.com> writes:

>> The net result is that dev_queue_xmit_nit() is called twice, once
>> for dev=eth0.2 then for dev=eth0.
>
> Maybe binding to all isn't such a good idea then.

Anyway I would expect the frame on eth0.2 and then on eth0 as well.
Anything different is crazy.
-- 
Krzysztof Halasa
