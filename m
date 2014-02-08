From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: REGRESSION f54b311142a92ea2e42598e347b84e1655caf8e3 tcp auto
 corking slows down iSCSI file system creation by factor of 70 [WAS: 4 TB
 VMFS creation takes 15 minutes vs 26 seconds]
Date: Sat, 08 Feb 2014 06:09:24 -0800
Message-ID: <1391868564.10160.91.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140206153640.GB4103@glanzmann.de>
	 <1391727771.14985.41.camel@haakon3.risingtidesystems.com>
	 <20140207051500.GB10916@glanzmann.de> <20140207075536.GB17815@glanzmann.de>
	 <1391801597.1155.28.camel@haakon3.risingtidesystems.com>
	 <20140207205142.GA8609@glanzmann.de> <20140208093808.GD16336@glanzmann.de>
	 <1391865273.10160.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140208133744.GA20512@glanzmann.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Ogness <john.ogness@linutronix.de>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	target-devel <target-devel@vger.kernel.org>,
	Linux Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Thomas Glanzmann <thomas@glanzmann.de>
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <20140208133744.GA20512@glanzmann.de>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2014-02-08 at 14:37 +0100, Thomas Glanzmann wrote:

> 
> It fixes my case but if you look at the round trip time it is not even
> close what it used to be. So while this fixes my problem I'm still for
> disabling it by default.
> 
> https://thomas.glanzmann.de/tmp/tcp_auto_corking_on_patched.pcap.bz2

This pcap was taken on which host ?

10.101.99.5 or  10.101.0.13 ?
