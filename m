From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] TCPCT-1: adding a sysctl
Date: Fri, 02 Oct 2009 23:06:30 +0200
Message-ID: <877hvdbj55.fsf@basil.nowhere.org>
References: <4AC57AC5.3080703@gmail.com> <20091001225705.788d38ba@nehalam>
	<4AC61505.8030701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:54280 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbZJBVG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 17:06:28 -0400
In-Reply-To: <4AC61505.8030701@gmail.com> (William Allen Simpson's message of "Fri, 02 Oct 2009 10:58:13 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson <william.allen.simpson@gmail.com> writes:
>
> Any suggestions for improvement?  Or general approval?

The patch seems incomplete, can't find callers for most of the new functions.

In general cookies fell a bit out of favour because they don't support window
scaling etc.  But you don't seem to fix that by putting that data into
the new option.

My immediate gut reaction is that it will be likely challenging to 
traverse many packet filters (which often have a tendency to drop
anything they don't know) with this option on. That is also what killed
ECN.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
