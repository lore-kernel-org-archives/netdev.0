From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.70-bk+ broken networking
Date: Wed, 04 Jun 2003 16:25:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EDE7FEB.2C7FAEC7@digeo.com>
References: <20030604161437.2b4d3a79.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, "David S. Miller" <davem@redhat.com>,
   netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> 
> Test machine running 2.5.70-bk latest can't boot because eth2 won't
> come up.  The same machine and configuration successfully brings up
> all the devices and runs on 2.5.70.

kjournald is stuck waiting for IO to complete against some buffer
during transaction commit.

I'd be suspecting block layer or device drivers.  What device driver
is handling your /var/log?
