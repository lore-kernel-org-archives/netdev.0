From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: RFC:  Redirect-Device
Date: Fri, 1 Apr 2005 12:28:44 +0300 (EEST)
Message-ID: <Pine.LNX.4.61.0504011222140.10960@netcore.fi>
References: <424C6089.1080507@candelatech.com> <Pine.LNX.4.61.0504010801170.6417@netcore.fi>
 <424CDBA9.80703@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <424CDBA9.80703@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 31 Mar 2005, Ben Greear wrote:
>> Is there something in your problem statement I'm missing?
>
> That would be similar to what I'm doing, but I'm not really trying
> to tunnel anything.  I am trying to duplicate the behaviour of two
> ethernet interfaces connected by an external cross-over cable, and I'm
> trying to duplicate it at the network-device interface level so that
> common tools (and my own tools) can treat these virtual interfaces
> just like ethernet interfaces.

Oh ok, what you seem to want is some kind of "Ethernet loopback++", 
but the "looped" packets should come back from a virtual interface 
instead of the same interface?

Btw, does the kernel support traditional loopback, so that at the last 
stage, just before sending a packet on the wire, it would be pushed 
back.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
