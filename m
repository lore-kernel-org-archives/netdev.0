From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: RTL 8139 stops RX after receiving a jumbo frame
Date: Sun, 26 Feb 2006 12:46:05 +0000
Message-ID: <1140957965.23286.9.camel@localhost.localdomain>
References: <44012D53.30700@undead.cc>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751094AbWBZMlm@vger.kernel.org>
To: John Zielinski <john_ml@undead.cc>
In-Reply-To: <44012D53.30700@undead.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sad, 2006-02-25 at 23:23 -0500, John Zielinski wrote:
> I'm surprised that the switch actually let the jumbo packet through onto 
> a 100Mbit link.  I'm going to see if I can find a non RTL 8139 card in 
> my parts bin and see what that one does.
> 
> What's the normal behavior for overruns on an interface?

Should drop the packet, but it may be triggering a driver path with a
bug. Is this repeatable and with multiple 8139 cards /
