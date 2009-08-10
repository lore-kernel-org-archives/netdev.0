From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [evb] Re: [PATCH][RFC] net/bridge: add basic VEPA support
Date: Mon, 10 Aug 2009 17:23:10 +0200
Message-ID: <200908101723.10832.arnd@arndb.de>
References: <0199E0D51A61344794750DC57738F58E67D2DCECBB@GVW1118EXC.americas.hpqcorp.net> <200908071329.44437.arnd@arndb.de> <005101ca1797$70dcf5b0$5296e110$@edu>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "'Stephen Hemminger'" <shemminger@linux-foundation.org>,
	"'Fischer, Anna'" <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	davem@davemloft.net, kaber@trash.net, adobriyan@gmail.com,
	"'Or Gerlitz'" <ogerlitz@voltaire.com>
To: evb@yahoogroups.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755383AbZHJPXW@vger.kernel.org>
In-Reply-To: <005101ca1797$70dcf5b0$5296e110$@edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 07 August 2009, Paul Congdon (UC Davis) wrote:
> 
> I don't think your scheme works too well because broadcast packet coming
> from other interfaces on br0 would get replicated and sent across the wire
> to ethB multiple times.

Right, that won't work. So the bridge patch for the hairpin turn
is still the best solution. Btw, how will that interact with
the bride-netfilter (ebtables) setup? Can you apply any filters
that work on current bridges also between two VEPA ports while
doing the hairpin turn?

	Arnd <><
