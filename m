From: <masaru.nagai.vx@renesas.com>
Subject: Re: [PATCH resend] Renesas Ethernet AVB driver
Date: Wed, 15 Apr 2015 10:01:05 +0900
Message-ID: <552DB851.8050800@renesas.com>
References: <2926619.fiYHPz1IBk@wasted.cogentembedded.com> <20150328082853.GA4255@localhost.localdomain> <5519D380.6070200@cogentembedded.com> <552C25BE.3070606@cogentembedded.com> <20150414052729.GA5179@netboy> <552CE890.3040103@cogentembedded.com> <20150414163002.GB4309@localhost.localdomain> <552D472A.6080309@cogentembedded.com> <20150414183000.GA5327@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <devicetree@vger.kernel.org>,
	<galak@codeaurora.org>, <netdev@vger.kernel.org>,
	<linux-sh@vger.kernel.org>, <mitsuhiro.kimura.kc@renesas.com>
To: <richardcochran@gmail.com>, <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20150414183000.GA5327@localhost.localdomain>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015=E5=B9=B404=E6=9C=8815=E6=97=A5 03:30, Richard Cochran wrote:
> On Tue, Apr 14, 2015 at 07:58:18PM +0300, Sergei Shtylyov wrote:
>>
>>     I tried to explain to you that I can't. We enter the device
>> configuration mode (from the operation mode) when e.g. the
>> *Ethernet* device is closed.
>
> Is this a hardware restriction?

Yes

> Logically speaking, the clock has nothing to do with the state of the
> Ethernet interface.  If the clock keeps ticking and you can access
> it, then there is no reason to return EBUSY just because the interfac=
e
> is down.

Oddly, This hardware is linked operation mode of the Ethernet I/F with =
PTP clock.

Best Regards,
Masaru Nagai
