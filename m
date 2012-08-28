From: Carsten Wolff <carsten@wolffcarsten.de>
Subject: Re: [PATCH 1/1] tcp: Wrong timeout for SYN segments
Date: Tue, 28 Aug 2012 10:44:35 +0200
Message-ID: <201208281044.40057.carsten@wolffcarsten.de>
References: <1345724123.5904.756.camel@edumazet-glaptop> <20120824.134231.41073001349178209.davem@davemloft.net> <20120825084819.GD430@linlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	hkjerry.chu@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexander Bergmann <alex@linlab.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120825084819.GD430@linlab.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Saturday 25 August 2012, Alexander Bergmann wrote:
> This patch increases the value of TCP_SYN_RETRIES to the value of 6,
> providing a retransmission window of 63secs.
> 
> The comments for SYN and SYNACK retries have also been updated to
> describe the current settings.

wouldn't it be nice, if the description of the corresponding sysctls in 
Documentation/networking/ip-sysctl.txt could be updated too?

Cheers
Carsten
