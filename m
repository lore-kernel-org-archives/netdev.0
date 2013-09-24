From: Matthew Hall <mh@mhcomputing.net>
Subject: Re: per-PID network stats files in /proc
Date: Tue, 24 Sep 2013 14:22:39 -0700
Message-ID: <20130924212238.GA6673@mhcomputing.net>
References: <20130924201536.GA3555@mhcomputing.net>
 <20130924134157.4fc22806@nehalam.linuxnetplumber.net>
 <20130924204442.GA5074@mhcomputing.net>
 <20130924140435.5881cf76@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from master.mhcomputing.net ([74.208.46.186]:49403 "EHLO
	mail.mhcomputing.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754511Ab3IXVY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 17:24:29 -0400
Content-Disposition: inline
In-Reply-To: <20130924140435.5881cf76@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 24, 2013 at 02:04:35PM -0700, Stephen Hemminger wrote:
> You could do what you want by putting each process in own network
> namespace, but that might be more work than you want to bother with.

Putting my one process or group of processes into one namespace, separate from 
the one the rest of the system uses, could be perfectly OK actually.

So I'm going to look into this and see if it's possible. At least it would 
give me a better route than where I am right now.

Thanks!
Matthew.
