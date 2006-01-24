From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [BUG] sky2 broken for Yukon PCI-E Gigabit Ethernet Controller
 11ab:4362 (rev 19)
Date: Tue, 24 Jan 2006 09:54:48 -0800
Message-ID: <20060124095448.7a77346c@dxpl.pdx.osdl.net>
References: <43D1C99E.2000506@t-online.de>
	<20060123101538.14d21bf4@dxpl.pdx.osdl.net>
	<43D52C69.5090707@t-online.de>
	<20060123112751.2e3f1b15@dxpl.pdx.osdl.net>
	<43D5F6DD.70702@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161016AbWAXRyx@vger.kernel.org>
To: Knut Petersen <Knut_Petersen@t-online.de>
In-Reply-To: <43D5F6DD.70702@t-online.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Jan 2006 10:43:57 +0100
Knut Petersen <Knut_Petersen@t-online.de> wrote:

> Stephen Hemminger schrieb:
> 
> >Could you try turning off rx checksumming (with ethtool).
> >	ethtool -K eth0 rx off
> >
> >There probably still are (generic) bugs in the netfilter code for CHECKSUM_HW
> >socket buffers.
> >
> >  
> >
> "ethtool -K eth0 rx off" does cure my problem with sky2.
> 
> Anybody is invited to send patches as the problem is 100% reproducible here.
>

Does it always show up on icmp only?

What are the iptables rules (iptables -L)

-- 
Stephen Hemminger <shemminger@osdl.org>
OSDL http://developer.osdl.org/~shemminger
