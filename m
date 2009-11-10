From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: sunrpc port allocation and IANA reserved list
Date: Wed, 11 Nov 2009 07:14:51 +0900
Message-ID: <1257891291.3044.50.camel@heimdal.trondhjem.org>
References: <4AF9A63B.6010101@nortel.com>
	 <1257875623.2834.19.camel@achroite.uk.solarflarecom.com>
	 <4AF9B2CF.6050305@nortel.com>
	 <1257884799.3044.7.camel@heimdal.trondhjem.org>
	 <4AF9D5D1.9040501@nortel.com>
	 <1257888720.2834.30.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Chris Friesen <cfriesen@nortel.com>, netdev@vger.kernel.org,
	Linux kernel <linux-kernel@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757236AbZKJWOy@vger.kernel.org>
In-Reply-To: <1257888720.2834.30.camel@achroite.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-11-10 at 21:32 +0000, Ben Hutchings wrote:
> On Tue, 2009-11-10 at 15:06 -0600, Chris Friesen wrote:
> > On 11/10/2009 02:26 PM, Trond Myklebust wrote: 
> > > Just use /proc/sys/sunrpc/{max,min}_resvport interface to restrict the
> > > range used to a safer one. That's what it is for...
> 
> Unless I'm much mistaken, that only affects in-kernel SunRPC users.

There shouldn't be that many non-kernel sunrpc users that require
privileged ports.

The exceptions I can think of are

      * the 'mount' program, if you are using the legacy binary mount
        interface. Use text mounts instead...
      * rpc.statd might also use privileged ports when booting the
        system when it needs to notify servers of the reboot. You can
        set that port number using the '-o' option.

Others? Do any of the NIS services require it?

Trond
