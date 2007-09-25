From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sky2: be more selective about FIFO watchdog
Date: Tue, 25 Sep 2007 00:10:02 -0400
Message-ID: <46F88A1A.6090007@pobox.com>
References: <20070920130349.252ecdb9@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34593 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751803AbXIYEKE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2007 00:10:04 -0400
In-Reply-To: <20070920130349.252ecdb9@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Be more selective about when to enable the ram buffer watchdog code.
> It is unnecessary on XL A3 or later revs, and with Yukon FE
> the buffer is so small (4K) that the watchdog detects false positives.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied


