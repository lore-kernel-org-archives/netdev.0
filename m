From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: [PATCH 2/2] c/r: Add AF_INET support (v3)
Date: Mon, 13 Jul 2009 14:02:08 -0500
Message-ID: <1247511728.15106.1.camel@merlyn>
References: <1246994776-1882-1-git-send-email-danms@us.ibm.com>
	 <1246994776-1882-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	Oren Laaden <orenl@cs.columbia.edu>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:36217 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970AbZGMTCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2009 15:02:17 -0400
Received: by ewy26 with SMTP id 26so2765926ewy.37
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2009 12:02:15 -0700 (PDT)
In-Reply-To: <1246994776-1882-3-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-07-07 at 12:26 -0700, Dan Smith wrote:
> Changes in v2:
>  - Check for data in the TCP out-of-order queue and fail if present

Why?  It seems that this would cause checkpoints to fail unexpectedly,
and is probably unnecessary in a migration scenario, because the peer
will retransmit the segments given appropriate ACKs.

  --  John

