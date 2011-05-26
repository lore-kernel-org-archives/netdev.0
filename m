From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH V6 0/4 net-next] macvtap/vhost TX zero-copy support
Date: Thu, 26 May 2011 13:31:25 -0700
Message-ID: <1306441885.5180.52.camel@localhost.localdomain>
References: <1306440020.5180.47.camel@localhost.localdomain>
	 <20110526202836.GA1951@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110526202836.GA1951@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-05-26 at 23:28 +0300, Michael S. Tsirkin wrote:
> On Thu, May 26, 2011 at 01:00:20PM -0700, Shirley Ma wrote:
> > 3. Add sleep in vhost shutting down instead of busy-wait for
> outstanding
> >    DMAs.
> 
> I still think this is not much better. We need to use a
> completion structure and wait on it instead.
> If this gets blocked thinkably a tx watchdog can fire and save us
> from blocking forver :) 

Ok, I can add a completion structure here.

Thanks
Shirley
