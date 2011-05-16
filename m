From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH V5 2/6 net-next] netdevice.h: Add zero-copy flag in
 netdevice
Date: Mon, 16 May 2011 20:47:33 +0100
Message-ID: <1305575253.2885.28.camel@bwh-desktop>
References: <1305574128.3456.23.camel@localhost.localdomain>
	 <1305574518.2885.25.camel@bwh-desktop>
	 <1305574680.3456.33.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mst@redhat.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305574680.3456.33.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-05-16 at 12:38 -0700, Shirley Ma wrote:
> On Mon, 2011-05-16 at 20:35 +0100, Ben Hutchings wrote:
> > Sorry, bit 31 is taken.  You get the job of turning features into a
> > wider bitmap.
> 
> :) will do it.

Bear in mind that feature masks are manipulated in many different
places.  This is not a simple task.

See previous discussion at:
http://thread.gmane.org/gmane.linux.network/193284
and especially:
http://thread.gmane.org/gmane.linux.network/193284/focus=193332

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
