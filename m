From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/3] net: msm_ipc: Add user-space support for MSM_IPC Router
Date: Thu, 9 Jun 2011 22:15:49 +0200
Message-ID: <201106092215.49079.arnd@arndb.de>
References: <1307555467-1530-1-git-send-email-kramasub@codeaurora.org> <4DF0FD8A.1000304@codeaurora.org> <20110609.123553.784125057506332397.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kramasub@codeaurora.org, netdev@vger.kernel.org,
	linux-arm-msm@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <20110609.123553.784125057506332397.davem@davemloft.net>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 09 June 2011 21:35:53 David Miller wrote:
> From: Karthikeyan Ramasubramanian <kramasub@codeaurora.org>
> Date: Thu, 09 Jun 2011 11:06:18 -0600
> 
> > Please let me know if you need any other information.
> 
> I don't agree with creating all of this non-trivial infrastructure
> for what seems to be an obscure protocol stack.
> 
> You can do all of this in userspace, it seems.

I can see some good use cases for having a socket to do IPC between OS
images that have a shared memory interconnect. What I see as most
problematic is to have it defined in a way that is tightly connected
to specific hardware from one vendor. If the protocol was defined
in a way that is useful for communication between virtual machines
(e.g. on top of virtio) and tranparent PCI bridges, it would probably
be much more acceptable.

	Arnd
