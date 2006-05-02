From: Andi Kleen <ak@suse.de>
Subject: Re: Van Jacobson's net channels and real-time
Date: Tue, 2 May 2006 17:58:52 +0200
Message-ID: <200605021758.52889.ak@suse.de>
References: <Pine.LNX.4.44L0.0604201819040.19330-100000@lifa01.phys.au.dk> <Pine.LNX.4.61.0604250717590.28279@chaos.analogic.com> <20060502124131.GA13160@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "linux-os (Dick Johnson)" <linux-os@analogic.com>,
	Auke Kok <sofar@foo-projects.org>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Ingo Oeser <ioe-lkml@rameria.de>,
	=?iso-8859-1?q?J=F6rn_Engel?= <joern@wohnheim.fh-wedel.de>,
	Ingo Oeser <netdev@axxeo.de>,
	"David S. Miller" <davem@davemloft.net>, simlo@phys.au.dk,
	linux-kernel@vger.kernel.org, mingo@elte.hu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:151 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S964906AbWEBQDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 May 2006 12:03:13 -0400
To: Vojtech Pavlik <vojtech@suse.cz>
In-Reply-To: <20060502124131.GA13160@suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 02 May 2006 14:41, Vojtech Pavlik wrote:
 
> You seem to be missing the fact that most of todays interrupts are
> delivered through the APIC bus, which isn't fast at all.

You mean slow right?  Modern x86s (anything newer than a P3) generally don't 
have an separate APIC bus anymore but just send messages over their main
processor connection.

-Andi
