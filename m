From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH 7/14] drivers/net/typhoon.c: delete double assignment
Date: Tue, 26 Oct 2010 07:52:12 -0400
Message-ID: <1288093932.14943.1.camel@lap75545.ornl.gov>
References: <1288088743-3725-1-git-send-email-julia@diku.dk>
 <1288088743-3725-8-git-send-email-julia@diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emroute4.ornl.gov ([160.91.86.27]:40530 "EHLO emroute4.ornl.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756233Ab0JZLwQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 07:52:16 -0400
In-reply-to: <1288088743-3725-8-git-send-email-julia@diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-10-26 at 12:25 +0200, Julia Lawall wrote:
> From: Julia Lawall <julia@diku.dk>
> 
> Delete successive assignments to the same location.  The current definition
> does not initialize the respRing structure, which has the same type as the
> cmdRing structure, so initialize that one instead.

> Signed-off-by: Julia Lawall <julia@diku.dk>

Acked-by: David Dillow <dave@thedillows.org>

> ---
> This changes the semantics and has not been tested.

tp->respRing.lastWrite is only an artifact of using a common struct for
the rings and is not otherwise used, so no change to semantics.
