From: David Brownell <david-b@pacbell.net>
Subject: Re: Must dev->set_multicast_list() complete before returning?
Date: Wed, 02 Apr 2003 08:18:11 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E8B0D43.2000003@pacbell.net>
References: <Pine.LNX.4.44.0304012242360.1685-100000@beohost.scyld.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Rask Ingemann Lambertsen <rask@sygehus.dk>, linux-net@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Donald Becker wrote:
> 
> I have not seen hardware where setting promiscuous mode is a queued
> command.  If you have such hardware, you may have to do some extra
> software filtering and accept missing some packets during transitions.

Every USB network adapter will need to queue such commands,
unless they don't support such operations at all.  So you
have probably seen such hardware, without realizing it!

I just looked ... none of them do any extra filtering.

- Dave
