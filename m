From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] sha2-256 truncation
Date: Fri, 9 Jan 2004 20:51:19 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040109205119.71482788.davem@redhat.com>
References: <3FFE6B72.9030808@logix.cz>
	<3FFE7E98.6060201@logix.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michal Ludvig <michal@logix.cz>
In-Reply-To: <3FFE7E98.6060201@logix.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 09 Jan 2004 11:12:40 +0100
Michal Ludvig <michal@logix.cz> wrote:

> Michal Ludvig told me that:
> 
> > the attached trivial patch corrects the truncation size of computed 
> > hashes that are used in IPsec ESP/AH packets for SHA2-256. All other 
> > hash algorithms use 96 bits as well as does SuperFreeS/WAN and FreeBSD 
> > also for SHA2-256. Only the native Linux sha2-256 used 128 bits what led 
> >  to incompatibility with other IPsec implementations.
> 
> Oops, sorry. I sent a reversed patch originally. Please use this one 
> instead.

Patch applied, thanks Michal.
