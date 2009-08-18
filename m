From: Willy Tarreau <w@1wt.eu>
Subject: Re: new ipdelay= option for faster netboot
Date: Tue, 18 Aug 2009 06:56:03 +0200
Message-ID: <20090818045603.GD11624@1wt.eu>
References: <20090814204305.GA31727@pengutronix.de> <4A89AC40.2040109@am.sony.com> <4A89DB15.6060101@am.sony.com> <20090817.180323.253692704.davem@davemloft.net> <4A8A0454.8000902@hp.com> <alpine.DEB.2.00.0908171942430.30426@asgard.lang.hm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, tim.bird@am.sony.com,
	r.schwebel@pengutronix.de, vda.linux@googlemail.com,
	linux-kernel@vger.kernel.org, linux-embedded@vger.kernel.org,
	arjan@linux.intel.com, kernel@pengutronix.de,
	netdev@vger.kernel.org
To: david@lang.hm
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751433AbZHRE42@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0908171942430.30426@asgard.lang.hm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 17, 2009 at 07:45:33PM -0700, david@lang.hm wrote:
> On Mon, 17 Aug 2009, Rick Jones wrote:
> 
> >David Miller wrote:
> >>I have card/switch combinations that take up to 10 seconds to
> >>negotiate a proper link.
> >
> >Gotta love it when things adhere to specs...
> 
> the default on Cisco switches is to wait 30 seconds before fully enabling 
> the port so that it can listen for spanning tree broadcasts.

And this causes a lot of trouble in high availability environments,
because the link is up but unusable. So if you're using it as a primary
bond link you can lose connectivity for that time. Fortunately, you can
configure the port in "switchport mode access", "portfast" mode to avoid
this annoying delay.

Willy
