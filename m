From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH resend] Renesas Ethernet AVB driver
Date: Tue, 14 Apr 2015 20:30:01 +0200
Message-ID: <20150414183000.GA5327@localhost.localdomain>
References: <2926619.fiYHPz1IBk@wasted.cogentembedded.com>
 <20150328082853.GA4255@localhost.localdomain>
 <5519D380.6070200@cogentembedded.com>
 <552C25BE.3070606@cogentembedded.com>
 <20150414052729.GA5179@netboy>
 <552CE890.3040103@cogentembedded.com>
 <20150414163002.GB4309@localhost.localdomain>
 <552D472A.6080309@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	masaru.nagai.vx@renesas.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <552D472A.6080309@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 14, 2015 at 07:58:18PM +0300, Sergei Shtylyov wrote:
> 
>    I tried to explain to you that I can't. We enter the device
> configuration mode (from the operation mode) when e.g. the
> *Ethernet* device is closed.

Is this a hardware restriction?

Logically speaking, the clock has nothing to do with the state of the
Ethernet interface.  If the clock keeps ticking and you can access
it, then there is no reason to return EBUSY just because the interface
is down.

Thanks,
Richard
