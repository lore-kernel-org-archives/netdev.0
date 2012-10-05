From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH 08/11] net: ll_temac: Do not use fixed mtu size
Date: Fri, 05 Oct 2012 07:58:51 +0200
Message-ID: <506E771B.2080102@monstr.eu>
References: <1349374497-9540-1-git-send-email-monstr@monstr.eu>  <1349374497-9540-8-git-send-email-monstr@monstr.eu> <1349378563.2817.27.camel@bwh-desktop.uk.solarflarecom.com>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349378563.2817.27.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/04/2012 09:22 PM, Ben Hutchings wrote:
> On Thu, 2012-10-04 at 20:14 +0200, Michal Simek wrote:
>> Use max mtu instead.
> [...]
>
> MTU does not include the Ethernet header so I have no idea how this is
> expected to work...

Right. This is wrong fix. It should be the same as is in axienet.
There is max_frm_size used which is mtu+header+tailer.
I will fix it.

Thanks,
Michal

-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
