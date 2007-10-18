From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [PATCH] pcnet32: fix non-napi packet reception
Date: Thu, 18 Oct 2007 15:23:08 -0400
Message-ID: <20071018192308.GB4004@csclub.uwaterloo.ca>
References: <1192665841.13749.4.camel@Linux.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Don Fry <pcnet32@verizon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:55728 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757040AbXJRTXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 15:23:13 -0400
Content-Disposition: inline
In-Reply-To: <1192665841.13749.4.camel@Linux.home>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 17, 2007 at 05:04:01PM -0700, Don Fry wrote:
> I have no objections myself.  It has been slowly moving that direction.
> First with the napi implementation, default off, labeled experimental.
> Then removing experimental and then making the default on.
> 
> If any other user of the pcnet32 has objections, now is the time to
> speak loudly!

I have used NAPI only on the pcnet32 for quite a while now.  In fact I
think a few of my local patches would break if I disabled NAPI.

__
Len Sorensen
