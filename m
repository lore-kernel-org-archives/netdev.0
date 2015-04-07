From: Andrew Bresticker <abrestic@chromium.org>
Subject: Re: [PATCH V2 2/2] stmmac: Add IMG Pistachio platform glue layer
Date: Tue, 7 Apr 2015 13:40:17 -0700
Message-ID: <CAL1qeaE__xSh-xFS43oLoVYzsc=hJXiYikw=OOt59-wOCTkYWQ@mail.gmail.com>
References: <1428356558-18367-1-git-send-email-abrestic@chromium.org>
	<1428356558-18367-2-git-send-email-abrestic@chromium.org>
	<2916148.ZqFzHAuDtr@wuerfel>
	<CAL1qeaFwt-VB6rUywHZ47gOx4fhd6LZLfvwqkydOtqWLkYbO8A@mail.gmail.com>
	<72BC0C8BD7BB6F45988A99382E5FBAE544490C96@hhmail02.hh.imgtec.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Govindraj Raja <Govindraj.Raja@imgtec.com>,
	Damien Horsley <Damien.Horsley@imgtec.com>
To: James Hartley <James.Hartley@imgtec.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <72BC0C8BD7BB6F45988A99382E5FBAE544490C96@hhmail02.hh.imgtec.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 7, 2015 at 10:16 AM, James Hartley <James.Hartley@imgtec.com> wrote:
>
>
>> -----Original Message-----
>> From: abrestic@google.com [mailto:abrestic@google.com] On Behalf Of
>> Andrew Bresticker
>> Sent: 06 April 2015 23:28
>> To: Arnd Bergmann; James Hartley
>> Cc: David S. Miller; Giuseppe Cavallaro; devicetree@vger.kernel.org;
>> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Govindraj Raja
>> Subject: Re: [PATCH V2 2/2] stmmac: Add IMG Pistachio platform glue layer
>>
>> On Mon, Apr 6, 2015 at 3:10 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> > On Monday 06 April 2015 14:42:38 Andrew Bresticker wrote:
>> >> At the moment, the only additional setup required for the DWMAC on
>> >> the IMG Pistachio SoC is to request and enable a separate gate clock
>> >> for the register interface.
>> >>
>> >> Signed-off-by: Andrew Bresticker <abrestic@chromium.org>
>> >> Signed-off-by: Govindraj Raja <govindraj.raja@imgtec.com>
>> >> Cc: James Hartley <james.hartley@imgtec.com>
>> >
>> > Why do you need a special glue driver for that?
>> >
>> > Since you don't do anything special, I'd say it should be possible to
>> > handle this with just the default driver.
>>
>> Right, at the moment we only need to request and enable a second clock,
>> which could be added to the core driver.  If we don't expect to have to
>> extend this driver to deal with other configurations (which IIRC there were
>> some concerns about when I wrote this), then I'm fine with folding this change
>> into the core driver - James?
>
> Weren't the concerns about USB not Ethernet?  I don't remember anything that
> would stop us extending the driver for eth.

OK, let's try this then: https://patchwork.kernel.org/patch/6174881/

-Andrew
