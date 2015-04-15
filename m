From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH resend] Renesas Ethernet AVB driver
Date: Wed, 15 Apr 2015 07:31:09 +0200
Message-ID: <20150415053108.GA5443@netboy>
References: <2926619.fiYHPz1IBk@wasted.cogentembedded.com>
 <20150328082853.GA4255@localhost.localdomain>
 <5519D380.6070200@cogentembedded.com>
 <552C25BE.3070606@cogentembedded.com>
 <20150414052729.GA5179@netboy>
 <552CE890.3040103@cogentembedded.com>
 <20150414163002.GB4309@localhost.localdomain>
 <552D472A.6080309@cogentembedded.com>
 <20150414183000.GA5327@localhost.localdomain>
 <552DB851.8050800@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sergei.shtylyov@cogentembedded.com, robh+dt@kernel.org,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, mitsuhiro.kimura.kc@renesas.com
To: masaru.nagai.vx@renesas.com
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <552DB851.8050800@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 15, 2015 at 10:01:05AM +0900, masaru.nagai.vx@renesas.com wrote:
> 
> Oddly, This hardware is linked operation mode of the Ethernet I/F with PTP clock.

In that case, you should remove the clock along with the interface.
Please see ixgbe as an example.

Thanks,
Richard
