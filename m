From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [Bcm43xx-dev] [Fwd: State of the Union: Wireless]
Date: Fri, 6 Jan 2006 10:23:53 -0800
Message-ID: <20060106102353.68d5f7ea@dxpl.pdx.osdl.net>
References: <1136541243.4037.18.camel@localhost>
	<200601061200.59376.mbuesch@freenet.de>
	<1136547494.7429.72.camel@localhost>
	<200601061245.55978.mbuesch@freenet.de>
	<1136549423.7429.88.camel@localhost>
	<43BE6697.3030009@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Michael Buesch <mbuesch@freenet.de>, jgarzik@pobox.com,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964826AbWAFSYu@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <43BE6697.3030009@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 06 Jan 2006 13:46:15 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Marcel Holtmann wrote:
> 
> >>I just personally liked the idea of having a device node in /dev for
> >>every existing hardware wlan card. Like we have device nodes for
> >>other real hardware, too. It felt like a bit of a "unix way" to do
> >>this to me. I don't say this is the way to go.
> >>If a netlink socket is used (which is possible, for sure), we stay with
> >>the old way of having no device node in /dev for networking devices.
> >>That is ok. But that is really only an implementation detail (and for sure
> >>a matter of taste).
> > 
> > 
> > At the OLS last year, I think the consensus was to use netlink for all
> > configuration task. However this was mainly driven by Harald Welte and
> > he might be able to talk about the pros and cons of netlink versus a
> > character device.
> 
> I think the main advantages of netlink over a character device is its
> flexible format, which is easily extendable, and multicast capability,
> which can be used to broadcast events and configuration changes. Its
> also good to have all the net stuff accessible in a uniform way.

Also netlink doesn't have the naming issues that /dev node would.

-- 
Stephen Hemminger <shemminger@osdl.org>
OSDL http://developer.osdl.org/~shemminger
