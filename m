From: KyoungSoo Park <kyoungso@cs.princeton.edu>
Subject: Re: is there any plan to support BSD accept filter?
Date: Fri, 14 Jan 2005 21:22:53 -0500
Message-ID: <41E87E7D.8040107@cs.princeton.edu>
References: <41E830BC.7000709@cs.princeton.edu> <20050114140540.76146b29@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050114140540.76146b29@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

yes. I agree that maybe an ugly hack to put that in the kernel.
What I want to do is to support such feature leaving as little footprint
as possible in the kernel, but specify whatever flexible policy you want
in the user level. 
I'm not sure netfilter module is the right place because it seems I need 
to do packet by packet processing, but I want to deal with a little higher
level than that as a start. (I'm not familar with netfilter, so please correct
me if I'm wrong.)

Anyway, thanks for your response.

KyoungSoo


Stephen Hemminger wrote:

>If you want to do these kind of stateful hacks, why not build a
>netfilter module to do it?
>
>
>  
>
