From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Need help debugging memory corruption
Date: Sun, 04 May 2008 16:24:49 +0200
Message-ID: <481DC731.5090303@gmail.com>
References: <20080503130951.091392ba@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Chris Snook <csnook@redhat.com>
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757262AbYEDOZG@vger.kernel.org>
In-Reply-To: <20080503130951.091392ba@osprey.hogchain.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Cliburn wrote, On 05/03/2008 08:09 PM:
...

> Here is the relevant console output when the bug is hit.  I note that
> the apparent corrupting data beginning at address 0xffff81010fcff402 is
> actually a received ethernet frame.  (The value 00:17:31:4e:9d:41 is
> the MAC address of the local host, corresponding to the destination
> address of a received frame.)
> 
> Can someone with more experience than me please take a look and give me
> some advice or explain what might be happening here?  (What may be
> obvious to you is probably not obvious to me.)

I'm definitely with less experience, so I wonder why it can't be
a simple race between atl1_clean_rx_ring() and something (maybe even
pending atl1_intr_rx()) on the other cpu writing skb while kfreeing?

Regards,
Jarek P.
