From: "David S. Miller" <davem@redhat.com>
Subject: Re: qfe problems on x86
Date: Tue, 23 Apr 2002 05:00:29 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20020423.050029.45364266.davem@redhat.com>
References: <20020423.044704.62892217.davem@redhat.com>
	<Pine.LNX.4.44.0204230817260.7811-100000@simon.ratbox.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: androsyn@ratbox.org
In-Reply-To: <Pine.LNX.4.44.0204230817260.7811-100000@simon.ratbox.org>
List-Id: netdev.vger.kernel.org

   From: Aaron Sethman <androsyn@ratbox.org>
   Date: Tue, 23 Apr 2002 08:19:43 -0400 (EDT)

   Hmmm...I just noticed something curious in the dmesg output I hadn't
   noticed before now..
   
   PCI: Failed to allocate resource 0(e0000000-dfffffff) for 01:01.0
   PCI: Failed to allocate resource 0(e0000000-dfffffff) for 01:02.0
   PCI: Failed to allocate resource 1(e0000000-dfffffff) for 01:02.0
   
   I'm not sure if that is normal or not, but those devices are part of the
   QFE.

It's an annoying message, but the only result is that the sunhme
driver uses other methods to select the MAC address.
