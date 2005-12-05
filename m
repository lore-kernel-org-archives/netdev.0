From: Michael Renzmann <netdev@nospam.otaku42.de>
Subject: Re: Broadcom 43xx first results
Date: Mon, 05 Dec 2005 19:14:03 +0100
Message-ID: <1133806444.4498.35.camel@gimli>
References: <E1Eiyw4-0003Ab-FW@www1.emo.freenet-rz.de>
	 <20051205190038.04b7b7c1@griffin.suse.cz>
Reply-To: netdev@nospam.otaku42.de
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mbuesch@freenet.de, linux-kernel@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de, NetDev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751395AbVLESO4@vger.kernel.org>
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20051205190038.04b7b7c1@griffin.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

On Mon, 2005-12-05 at 19:00 +0100, Jiri Benc wrote:
> Why yet another attempt to write 802.11 stack? Sure, the one currently
> in the kernel is unusable and everybody knows about it. But why not to
> improve code opensourced by Devicescape some time ago instead of
> inventing the wheel again and again?

Or, in case there is some unknown objection to the mentioned code: use
the 802.11 stack that comes along with MadWifi, which provides things
like virtual interfaces (for multiple SSID support on one physical card)
and WPA support.

Although I'm a bit biased towards MadWifi, I'd second your suggestion to
make use of the Devicescape code. The benefit of having a fully-blown
802.11 stack in the kernel that drivers can make use of has been
discussed before, so I won't go into that yet again.

Bye, Mike
