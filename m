From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: Re: usb/net/hso: WARNING: ungligned urb->setup_dma
Date: Tue, 28 Feb 2017 17:21:18 +0100
Message-ID: <36230d64-4ba0-7515-1131-ecf3ab9f352c@i2se.com>
References: <20170228082810.syn656o2zzms7urf@tarshish>
 <20170228120134.4f65yihw7x22hfwd@tarshish>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: John Youn <johnyoun@synopsys.com>, netdev@vger.kernel.org,
 Olivier Sobrie <olivier@sobrie.be>, linux-rpi-kernel@lists.infradead.org,
 linux-arm-kernel@lists.infradead.org
To: Baruch Siach <baruch@tkos.co.il>, linux-usb@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170228120134.4f65yihw7x22hfwd@tarshish>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Baruch,

Am 28.02.2017 um 13:01 schrieb Baruch Siach:
> Hi linux-usb list,
>
> (Dropped Jan's bouncing address, added Rpi3 platform lists)
>
> On Tue, Feb 28, 2017 at 10:28:10AM +0200, Baruch Siach wrote:
>> Hi linux-usb list,
>>
>> I'm hitting this warning consistently on my Raspberry Pi 3 running kernel
>> v4.10.1 with some unrelated device tree changes, and a debug print (below).
>> The device identifies as "GlobeTrotter HSDPA Modem", VID: 0af0, PID: 6971.
>> The warning triggers consistently on first write access to /dev/ttyHS0 that
>> ModemManager attempts. The first line in the log is my debug print.
> I tested the same hardware successfully on an i.MX6 CuBox-i (ARM32) using the
> same kernel version (4.10.1), and on an x86_64 PC (4.9). So this seems to be
> platform specific. I don't have any other ARM64 machine at the moment, though.

those platforms usually doesn't use the dwc2 USB host controller. So it 
should be tested with another dwc2 platform.

Is the issue reproducible with other USB devices like keyboards?
Are you using arm64 defconfig?
Are you able to bisect this issue?

Stefan
