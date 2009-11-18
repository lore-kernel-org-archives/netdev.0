From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/3] macvlan: implement VEPA and private mode
Date: Wed, 18 Nov 2009 10:48:04 +0100
Message-ID: <200911181048.04233.arnd@arndb.de>
References: <1258497551-25959-1-git-send-email-arnd@arndb.de> <1258497551-25959-3-git-send-email-arnd@arndb.de> <4B03974D.3010708@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	Patrick Mullaney <pmullaney@novell.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org,
	virtualization@lists.linux-foundation.com,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756935AbZKRJtb@vger.kernel.org>
In-Reply-To: <4B03974D.3010708@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 18 November 2009, Eric Dumazet wrote:
> > +                     macvlan_broadcast(skb, port, NULL, MACVLAN_MODE_VEPA
> > +                             | MACVLAN_MODE_VEPA | MACVLAN_MODE_BRIDGE);
> 
> typo here, you probably meant MACVLAN_PRIVATE | MACVLAN_VEPA | MACVLAN_BRIDGE 

Well spotted. One last minute-change gone wrong.

Thanks,

	Arnd <><
