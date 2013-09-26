From: Matthew Hall <mh@mhcomputing.net>
Subject: Re: per-PID network stats files in /proc
Date: Thu, 26 Sep 2013 13:12:52 -0700
Message-ID: <20130926201252.GA32748@mhcomputing.net>
References: <20130924201536.GA3555@mhcomputing.net>
 <20130924134157.4fc22806@nehalam.linuxnetplumber.net>
 <20130924204442.GA5074@mhcomputing.net>
 <20130924140435.5881cf76@nehalam.linuxnetplumber.net>
 <20130924212238.GA6673@mhcomputing.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from master.mhcomputing.net ([74.208.46.186]:49428 "EHLO
	mail.mhcomputing.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854Ab3IZUOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 16:14:45 -0400
Content-Disposition: inline
In-Reply-To: <20130924212238.GA6673@mhcomputing.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 24, 2013 at 02:22:39PM -0700, Matthew Hall wrote:
> On Tue, Sep 24, 2013 at 02:04:35PM -0700, Stephen Hemminger wrote:
> > You could do what you want by putting each process in own network
> > namespace, but that might be more work than you want to bother with.
> 
> Putting my one process or group of processes into one namespace, separate from 
> the one the rest of the system uses, could be perfectly OK actually.
> 
> So I'm going to look into this and see if it's possible. At least it would 
> give me a better route than where I am right now.
> 
> Thanks!
> Matthew.

Hi Stephen,

I took a look at this possibility and it seems very powerful but not so easy 
to use. Is there a way to make a netns that's like a "child node" of another 
netns, and inherits all the settings of the default one, unless I configured 
separate settings for this "child netns"? Otherwise the netns has to duplicate 
everything already configured on the host system even if it's unchanged from 
the standard settings.

Thanks,
Matthew.
