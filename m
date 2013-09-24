From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: per-PID network stats files in /proc
Date: Tue, 24 Sep 2013 14:04:35 -0700
Message-ID: <20130924140435.5881cf76@nehalam.linuxnetplumber.net>
References: <20130924201536.GA3555@mhcomputing.net>
	<20130924134157.4fc22806@nehalam.linuxnetplumber.net>
	<20130924204442.GA5074@mhcomputing.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matthew Hall <mh@mhcomputing.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:41285 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753836Ab3IXVEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 17:04:39 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so5025092pbc.7
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 14:04:38 -0700 (PDT)
In-Reply-To: <20130924204442.GA5074@mhcomputing.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Sep 2013 13:44:42 -0700
Matthew Hall <mh@mhcomputing.net> wrote:

> On Tue, Sep 24, 2013 at 01:41:57PM -0700, Stephen Hemminger wrote:
> > No. because most of these would be associated with global state.
> > Even sockets can be shared between PID's.
> 
> OK. So if this is true, then I feel compelled to ask, why does 
> /proc/PID/net/snmp exist in the first place, if it would never really work?
> 
> Thanks,
> Matthew.

/proc/PID/net is symlink to the processes network namespace.

You could do what you want by putting each process in own network
namespace, but that might be more work than you want to bother with.
