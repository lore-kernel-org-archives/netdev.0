From: Christian Schmid <webmaster@rapidforum.com>
Subject: Re: TCP-Protection is really a pain...
Date: Thu, 03 Feb 2005 21:19:19 +0100
Message-ID: <42028747.6060602@rapidforum.com>
References: <4201A382.1020208@rapidforum.com>	<20050202205437.571a702b@localhost.localdomain>	<4201B4EA.2030101@rapidforum.com>	<20050203113335.46396c11@dxpl.pdx.osdl.net>	<42028278.7040008@rapidforum.com> <20050203121503.4f122779@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050203121503.4f122779@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: on

What exactly is tcp segmentation offload? Where can I read more about it? Should I disable it or is 
this not a good idea?

Stephen Hemminger wrote:
> On Thu, 03 Feb 2005 20:58:48 +0100
> Christian Schmid <webmaster@rapidforum.com> wrote:
> 
> E1000 support TSO. To check if it is enabled do:
> 	ethtool -k eth0
> To turn it off use.
> 	ethtool -K eth0 tso off
> 
> You get the idea..
> 
