From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Hard freeze with 2.6.10-rc3 and QoS, worked fine with 2.6.9
Date: Wed, 8 Dec 2004 11:30:14 -0800
Message-ID: <20041208113014.3dcad5f5@dxpl.pdx.osdl.net>
References: <1102380430.6103.6.camel@buffy>
	<20041206224441.628e7885.akpm@osdl.org>
	<1102422544.1088.98.camel@jzny.localdomain>
	<41B5E188.5050800@trash.net>
	<20041207170748.GF1371@postel.suug.ch>
	<41B5E722.2080600@trash.net>
	<20041207213053.6bb602c1.davem@davemloft.net>
	<1102507470.1051.27.camel@jzny.localdomain>
	<41B73263.4040706@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, "David S. Miller" <davem@davemloft.net>,
	tgraf@suug.ch, akpm@osdl.org, tomc@compaqnet.fr,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261328AbULHTbm@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41B73263.4040706@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I don't know if this is related but something broke netem after 2.6.10-rc2
Now a simple request to delay 10ms ends up taking 1000ms.

Still narrowing down the changeset, but it isn't a change in netem
or tc utils since these didn't change.
