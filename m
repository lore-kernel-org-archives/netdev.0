From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: [PATCH 1/1] net: nps_enet: Disable interrupts before napi
 reschedule
Date: Thu, 2 Jun 2016 15:43:30 +0530
Message-ID: <575006CA.6070705@synopsys.com>
References: <1464264006-26627-1-git-send-email-eladkan@mellanox.com>
 <20160529.223542.1386340561946869732.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <noamca@mellanox.com>, <linux-kernel@vger.kernel.org>,
	<Alexey.Brodkin@synopsys.com>, <netdev@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <eladkan@mellanox.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20160529.223542.1386340561946869732.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 30 May 2016 11:05 AM, David Miller wrote:
> From: Elad Kanfi <eladkan@mellanox.com>
> Date: Thu, 26 May 2016 15:00:06 +0300
> 
>> From: Elad Kanfi <eladkan@mellanox.com>
>>
>> Since NAPI works by shutting down event interrupts when theres
>> work and turning them on when theres none, the net driver must
>> make sure that interrupts are disabled when it reschedules polling.
>> By calling napi_reschedule, the driver switches to polling mode,
>> therefor there should be no interrupt interference.
>> Any received packets will be handled in nps_enet_poll by polling the HW
>> indication of received packet until all packets are handled.
>>
>> Signed-off-by: Elad Kanfi <eladkan@mellanox.com>
>> Acked-by: Noam Camus <noamca@mellanox.com>
> 
> Applied.
> 

ARC osci platform in 4.6 currently have broken networking. This needs a stable
backport to 4.6

Upstream 86651650d16a359e4 ("net: nps_enet: Disable interrupts before napi
reschedule")

Thx,
-Vineet
