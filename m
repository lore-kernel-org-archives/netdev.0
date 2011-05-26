From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH V5 2/6 net-next] netdevice.h: Add zero-copy flag in
 netdevice
Date: Thu, 26 May 2011 12:11:17 -0700
Message-ID: <1306437077.5180.9.camel@localhost.localdomain>
References: <1305729507.32080.6.camel@localhost.localdomain>
	 <20110518154746.GA21378@redhat.com>
	 <1305734857.32080.53.camel@localhost.localdomain>
	 <20110518163633.GB22001@redhat.com>
	 <1305737140.32080.59.camel@localhost.localdomain>
	 <20110518165138.GD22001@redhat.com>
	 <1305738028.32080.66.camel@localhost.localdomain>
	 <1305834169.32080.81.camel@localhost.localdomain>
	 <20110519234154.GA13784@redhat.com>
	 <1306363780.26270.44.camel@localhost.localdomain>
	 <20110526084916.GA17928@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110526084916.GA17928@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-05-26 at 11:49 +0300, Michael S. Tsirkin wrote:
> > 
> > > - SG support
> > > - HIGHDMA support (on arches where this makes sense)
> > 
> > This can be checked by device flags.
> 
> OK, but pls note that SG can get turned off dynamically.

Tested the patch w/i SG dynmically on/off and tcpdump suspended.
