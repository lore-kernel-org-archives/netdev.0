From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] igb:  add module param to set max-rss-queues.
Date: Mon, 27 Mar 2017 09:26:20 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFBA6BB@AcuExch.aculab.com>
References: <1490389127-23171-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: "'greearb@candelatech.com'" <greearb@candelatech.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.186]:62751 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751592AbdC0J1h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 05:27:37 -0400
In-Reply-To: <1490389127-23171-1-git-send-email-greearb@candelatech.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: greearb@candelatech.com
> Sent: 24 March 2017 20:59
> From: Ben Greear <greearb@candelatech.com>
> 
> In systems where you may have a very large number of network
> adapters, certain drivers may consume an unfair amount of
> IRQ resources.  So, allow a module param that will limit the
> number of IRQs at driver load time.  This way, other drivers
> (40G Ethernet, for instance), which probably will need the
> multiple IRQs more, will not be starved of IRQ resources.

ISTM that the functions for allocating MSI-X should allow a
driver to request additional interrupts after the original probe.

Then drivers than can use additional interrupts but get probed
early won't use up all the vectors before other drivers get
a chance.

	David
