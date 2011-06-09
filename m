From: Bryan Huntsman <bryanh@codeaurora.org>
Subject: Re: [PATCH 2/3] net: msm_ipc: Add user-space support for MSM_IPC
 Router
Date: Thu, 09 Jun 2011 13:41:53 -0700
Message-ID: <4DF13011.6060003@codeaurora.org>
References: <1307555467-1530-1-git-send-email-kramasub@codeaurora.org> <4DF0FD8A.1000304@codeaurora.org> <20110609.123553.784125057506332397.davem@davemloft.net> <201106092215.49079.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kramasub@codeaurora.org,
	netdev@vger.kernel.org, linux-arm-msm@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <201106092215.49079.arnd@arndb.de>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/09/2011 01:15 PM, Arnd Bergmann wrote:
> I can see some good use cases for having a socket to do IPC between OS
> images that have a shared memory interconnect. What I see as most
> problematic is to have it defined in a way that is tightly connected
> to specific hardware from one vendor. If the protocol was defined
> in a way that is useful for communication between virtual machines
> (e.g. on top of virtio) and tranparent PCI bridges, it would probably
> be much more acceptable.
> 
> 	Arnd

Yeah, we're trying to figure out the best way to do socket-based
communication between various images within a SoC.  I was thinking that
some kind of registration scheme would be necessary for the new AF to
support different SoCs and communication mechanisms.  We'll take a look
at ways to have a generic implementation.  Thanks.

- Bryan

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
