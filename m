From: Christian Schmid <webmaster@rapidforum.com>
Subject: Re: TCP-Protection is really a pain...
Date: Thu, 03 Feb 2005 23:29:10 +0100
Message-ID: <4202A5B6.5080903@rapidforum.com>
References: <4201A382.1020208@rapidforum.com>	<20050202205437.571a702b@localhost.localdomain>	<4201B4EA.2030101@rapidforum.com>	<20050203113335.46396c11@dxpl.pdx.osdl.net>	<42028278.7040008@rapidforum.com> <20050203121503.4f122779@dxpl.pdx.osdl.net> <42028747.6060602@rapidforum.com> <4202A206.7060100@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4202A206.7060100@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I turned it off and without it, I was unable to reproduce any stalls anymore.

Jeff Garzik wrote:
> Christian Schmid wrote:
> 
>> What exactly is tcp segmentation offload? Where can I read more about 
>> it? Should I disable it or is this not a good idea?
> 
> 
> It's an optimization designed to reduce CPU usage for zero-copy apps 
> (those that use sendfile(2)).
> 
> It would be a useful datapoint to disable TSO, and see if that improves 
> things for you.
> 
>     Jeff
> 
> 
> 
> 
