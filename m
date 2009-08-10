From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v8)
Date: Mon, 10 Aug 2009 16:02:35 -0500
Message-ID: <20090810210235.GB24373@us.ibm.com>
References: <1249918379-29414-1-git-send-email-danms@us.ibm.com> <1249918379-29414-6-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:46175 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753615AbZHJVCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 17:02:46 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e37.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7AL1q7p013989
	for <netdev@vger.kernel.org>; Mon, 10 Aug 2009 15:01:52 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7AL2dK5252004
	for <netdev@vger.kernel.org>; Mon, 10 Aug 2009 15:02:42 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7AL2bJ9014705
	for <netdev@vger.kernel.org>; Mon, 10 Aug 2009 15:02:38 -0600
Content-Disposition: inline
In-Reply-To: <1249918379-29414-6-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Dan Smith (danms@us.ibm.com):
> This patch adds basic checkpoint/restart support for AF_UNIX sockets.  It
> has been tested with a single and multiple processes, and with data inflight
> at the time of checkpoint.  It supports socketpair()s, path-based, and
> abstract sockets.

Thanks, Dan.  Apart from the double-free on error case in
sock_copy_buffers(), this looks very good to me.  So with that
change, please feel free to add:

Acked-by: Serge Hallyn <serue@us.ibm.com>

Oren, pls do consider pulling this into v18.

Dan, do you have any testcases (even just descriptions of
how to test, which i'll then try to script) i can add to
cr_tests?

thanks,
-serge
