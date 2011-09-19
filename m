From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: iptables 2.6.38, can kernel erroneously bypass PREROUTING ?
Date: Sun, 18 Sep 2011 22:26:42 -0300
Message-ID: <20110919012642.GB16718@khazad-dum.debian.net>
References: <4E7616F5.7080009@cdi.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Martin Devera <martin.devera@cdi.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4E7616F5.7080009@cdi.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(netdev added to cc)

On Sun, 18 Sep 2011, Martin Devera wrote:
> we have problem with high-bw router (1gbit, conntrack, nat, htb qos)
> where after some time (weeks) DNAT stops working.
> I tried to include "-t raw -A PREROUTING -i eth0" an it got ZERO hits
> while -i eth1 has many.
> Thus DNAT (in -t nat) doesn't work but interestingly conntrack (and thus
> SNAT records) is ok - packets from eth0 sems to be routed.
> Only they "somehow" skip all PREROUTING chains.. But from sources
> I can find no way how only eth0 pkts could skip PREROUTING but still
> be routed and contracked ... Anyone has a clue ?
> 
> A didn't more investigation as I had to reboot it - it always helps.

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh
