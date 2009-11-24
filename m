From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/4] veth: move loopback logic to common location
Date: Tue, 24 Nov 2009 14:13:09 +0100
Message-ID: <200911241413.09214.arnd@arndb.de>
References: <1259024166-28158-1-git-send-email-arnd@arndb.de> <200911241034.43961.arnd@arndb.de> <4B0BB818.6090509@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Anna Fischer <anna.fischer@hp.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Patrick Mullaney <pmullaney@novell.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932893AbZKXNPO@vger.kernel.org>
In-Reply-To: <4B0BB818.6090509@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 24 November 2009, Patrick McHardy wrote:
> I don't think its necessary, we bypass outgoing queuing anyways.
> But if you'd want to add it, just keeping the skb->mark clearing
> in veth should work from what I can tell.

Ok, I won't bother with it for now then.

	Arnd <><
