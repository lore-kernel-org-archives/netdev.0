From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 0/0] sky2: update for 2.6.24
Date: Thu, 30 Aug 2007 13:36:11 -0700
Message-ID: <20070830133611.3fd4922f@freepuppy.rosehill.hemminger.net>
References: <20070829193922.078561651@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46941 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761511AbXH3UhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2007 16:37:11 -0400
In-Reply-To: <20070829193922.078561651@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patch number 10 doesn't work right, it causes excess interrupts
and console messages.
8 & 9 are only needed for #10, so skip them as well.

So please only apply 1-7 to netdev for 2.6.24
-- 
Stephen Hemminger <shemminger@linux-foundation.org>
