From: Jeroen Vreeken <pe1rxq@amsat.org>
Subject: Re: [PATCH] ax25 & netrom fixes for 2.6
Date: Tue, 12 Aug 2003 22:59:12 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030812225912.C28977@jeroen.pe1rxq.ampr.org>
References: <20030812194653.A28977@jeroen.pe1rxq.ampr.org> <20030812124820.2ab57161.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030812124820.2ab57161.shemminger@osdl.org>; from shemminger@osdl.org on Tue, Aug 12, 2003 at 21:48:20 +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 2003.08.12 21:48:20 +0200 Stephen Hemminger wrote:
> You lost a critical fix to ax25;  it oop's if I bring up any device
> then do "ifconfig -a" due to use after free.
> 
> PLEASE do some debugging with some of the kernel debugging options
> enabled!

Which fix exactly did I miss? the only thing I see in your patch is the
change to use sock_put in ax25_destroy_sock() and that was in my original
patch...

btw, I do have debugging enabled...

Jeroen
