From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: RFC:  Redirect-Device
Date: Fri, 1 Apr 2005 08:03:39 +0300 (EEST)
Message-ID: <Pine.LNX.4.61.0504010801170.6417@netcore.fi>
References: <424C6089.1080507@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <424C6089.1080507@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 31 Mar 2005, Ben Greear wrote:
> I created a new virtual ethernet device that solves a problem
> I faced.  I thought I'd see if anyone else sees a use for this,
> and if so, I'll work to polish the patch so that it can be
> accepted into the kernel.

Unless I'm misunderstanding..

You seem to have pretty much duplicated the work by Lennert (see 
thread "[PATCH][RFC] etherip: Ethernet-in-IPv4 tunneling" from 
January).

That particular thread seemed to conclude that instead of creating 
something new, you can just use GRE tunneling to bridge Ethernet, and 
it works in a multi-vendor environment as well.

Is there something in your problem statement I'm missing?

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
