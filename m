From: Henrik Petander <lpetande@tml.hut.fi>
Subject: Re: Bug in ipv6 ipsec in handling of packets with extension headers
Date: Thu, 05 Jun 2003 15:59:32 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EDF3EB4.8010105@tml.hut.fi>
References: <3EDF36AA.9020403@tml.hut.fi> <20030605.051709.104035049.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030605.051709.104035049.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
>    From: Henrik Petander <lpetande@tml.hut.fi>
>    Date: Thu, 05 Jun 2003 15:25:14 +0300
>    
>    A possible fix is to change the pointer into an offset from the start of 
>    the packet and use the offset later to set the nexthdr value in the 
>    extension header.
> 
> Please indicate the version of the sources you are looking
> at when making reports.

Sure, esp6.c bitkeeper version was 1.16. Also a fix to the bug report: 
the problem is with esp6 and not with ah6, which does not use the 
get_offset function.

Henrik
