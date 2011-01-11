From: Chris Rankin <rankincj@yahoo.com>
Subject: RE: [E1000-devel] [e100] Page allocation failure warning(?) in 2.6.36.3
Date: Tue, 11 Jan 2011 00:52:37 -0800 (PST)
Message-ID: <838977.21111.qm@web121703.mail.ne1.yahoo.com>
References: <F675EE07F28A0A4E933E5F9DD28672FB01197E098F@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Tushar NDave <tushar.n.dave@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web121703.mail.ne1.yahoo.com ([98.138.90.124]:45158 "HELO
	web121703.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751035Ab1AKIwj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jan 2011 03:52:39 -0500
In-Reply-To: <F675EE07F28A0A4E933E5F9DD28672FB01197E098F@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--- On Tue, 11/1/11, Dave, Tushar N <tushar.n.dave@intel.com> wrote:
The reason I asked you about bridge is because I have
> noticed "br0: port 1(eth1) entering learning state" in the
> dmesg log you sent.
> I am trying to figure out exactly what sequence of commands
> you run that produce this message " br0: port 1(eth1)
> entering learning state" in log.

Tushar,

Ah, sorry. I thought you were referring to a PCI bridge, or something similar.

The br0 interface contains the eth1 and eth2 interfaces, which each connects to a PC on the private LAN. The eth0 interface connects to the ADSL router, and br0 holds the PC's internal LAN IP address. (eth0, eth1 and eth2 are all e100 interfaces, of course.)

It's impossible to state whether the problem *only* happens when I use the bridge because:
a) I've always used the bridge, and need to for the LAN to work, and
b) the problem is both rare and intermittent, even when it does happen. I certainly didn't notice it with the 2.6.36.2 kernel, nor any of the 2.6.34 or 2.6.35 kernels, although the fact that I did with the 2.6.33.6 kernel suggests it was present in all those kernels anyway.

I'll send you the bridge setup and ifconfig information later; I'm not in front of that PC right now.

Thanks,
Chris



      
