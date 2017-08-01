From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3 1/2] ravb: add wake-on-lan support via magic packet
Date: Tue, 1 Aug 2017 16:25:15 +0300
Message-ID: <847f5ce9-c5c5-956b-5c8f-a0a03bece3bc@cogentembedded.com>
References: <20170801101437.9020-1-niklas.soderlund+renesas@ragnatech.se>
 <20170801101437.9020-2-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: =?UTF-8?Q?Niklas_S=c3=b6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170801101437.9020-2-niklas.soderlund+renesas@ragnatech.se>
Content-Language: en-MW
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 08/01/2017 01:14 PM, Niklas Söderlund wrote:

> WoL is enabled in the suspend callback by setting MagicPacket detection
> and disabling all interrupts expect MagicPacket. In the resume path the
> driver needs to reset the hardware to rearm the WoL logic, this prevents
> the driver from simply restoring the registers and to take advantage of
> that ravb was not suspended to reduce resume time. To reset the
> hardware the driver closes the device, sets it in reset mode and reopens
> the device just like it would do in a normal suspend/resume scenario
> without WoL enabled, but it both closes and opens the device in the
> resume callback since the device needs to be reset for WoL to work.
> 
> One quirk needed for WoL is that the module clock needs to be prevented
> from being switched off by Runtime PM. To keep the clock alive the
> suspend callback need to call clk_enable() directly to increase the
> usage count of the clock. Then when Runtime PM decreases the clock usage
> count it won't reach 0 and be switched off.

> Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>

[...]

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
