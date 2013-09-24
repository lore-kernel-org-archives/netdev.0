From: Matthew Hall <mh@mhcomputing.net>
Subject: Re: per-PID network stats files in /proc
Date: Tue, 24 Sep 2013 13:44:42 -0700
Message-ID: <20130924204442.GA5074@mhcomputing.net>
References: <20130924201536.GA3555@mhcomputing.net>
 <20130924134157.4fc22806@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from master.mhcomputing.net ([74.208.46.186]:49401 "EHLO
	mail.mhcomputing.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753916Ab3IXUqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 16:46:33 -0400
Content-Disposition: inline
In-Reply-To: <20130924134157.4fc22806@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 24, 2013 at 01:41:57PM -0700, Stephen Hemminger wrote:
> No. because most of these would be associated with global state.
> Even sockets can be shared between PID's.

OK. So if this is true, then I feel compelled to ask, why does 
/proc/PID/net/snmp exist in the first place, if it would never really work?

Thanks,
Matthew.
