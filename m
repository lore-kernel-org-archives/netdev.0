From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] natsemi: long cable, short cable
Date: Fri, 11 Feb 2005 17:07:25 -0500
Message-ID: <420D2C9D.3090209@pobox.com>
References: <20050208141849.GC23971@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050208141849.GC23971@suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Olaf Kirch wrote:
> The current version of the natsemi driver comes with a workaround
> for a hardware problem that causes link failures on short cables.
> Unfortunately, this workaround causes massive link failures on _long_
> cables (270-300ft). This patch adds a module parameter to disable
> the workaround if required.
> 
> Signed-off-by: Olaf Kirch <okir@suse.de>


I grudgingly applied this.

Hopefully someone will create a private ioctl or ethtool option for 
this, rather than a module option.  This setting needs to be per-interface.

	Jeff
