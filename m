From: Ben Greear <greearb@candelatech.com>
Subject: Re: 82540EM very slow on 2.6.0-test[45]
Date: Thu, 11 Sep 2003 15:19:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F60F4F4.2070107@candelatech.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010124F030@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rwhron@earthlink.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E010124F030@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Feldman, Scott wrote:
>>I tried 4 Solaris servers.  2 had forced full duplex
>>and 100 Mbps.  Those are slow.  2 other Solaris servers
>>on the same LAN as the "slow" Solaris servers are fast.
>>These "fast" servers are using default settings (which
>>should also be 100 Mbps full-duplex).
> 
> 
> Maybe someone else on the list has some suggestions?  I think we're
> troubleshooting your network now.
> 
> Is it just ftp that's slow?  What's in the path between the Linux and
> the "slow" Solaris server?  Can you shorten the path?  What happens if
> you don't force 100/full on the "slow" Solaris server?

I know that Becker always yells and folks that force duplex.  It is
evidently not a good thing to do.

Also, I've seen linux ftp get very poor results when there is any
latency in the link.  That latency could include the solaris machine
reading from it's HD, etc.

Try saving the file locally to /dev/null, that takes at least one HD
out of the picture.  Also try using some network transfer tool that
does not read or write to disk.  I think ttcp might be good for that.

> 
> -scott
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
