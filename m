From: David Miller <davem@davemloft.net>
Subject: Re: expected behavior of PF_PACKET on NETIF_F_HW_VLAN_RX device?
Date: Thu, 01 Nov 2007 14:58:28 -0700 (PDT)
Message-ID: <20071101.145828.36424380.davem@davemloft.net>
References: <20071031.215025.195350296.davem@davemloft.net>
	<4729EAFF.9050606@candelatech.com>
	<18218.18134.353553.189622@zeus.sw.starentnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, shemminger@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bguo@sw.starentnetworks.com
To: djohnson+linux-kernel@sw.starentnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45568
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753485AbXKAV63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 17:58:29 -0400
In-Reply-To: <18218.18134.353553.189622@zeus.sw.starentnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com>
Date: Thu, 1 Nov 2007 17:36:22 -0400

> bad csum on tx packets as reported by tcpdump is also an issue.

We provide a tag to userspace that tcpdump should use to see that the
HW is going to checksum the packet, and therefore it should elide
trying to verify the checksums.

It's not a kernel issue.
