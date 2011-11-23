From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: Missing TCP SYN on loopback, retransmits after 1s
Date: Wed, 23 Nov 2011 02:44:13 +0100
Message-ID: <20111123014412.GC4834@nuttenaction>
References: <20111122181320.38a70cf8@telperion.jlyo.org>
 <20111122.192338.1206677511966747729.davem@davemloft.net>
 <20111122183727.01ab6f04@telperion.jlyo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesse Young <jlyo@jlyo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:38084 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755319Ab1KWBoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 20:44:15 -0500
Content-Disposition: inline
In-Reply-To: <20111122183727.01ab6f04@telperion.jlyo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Jesse Young | 2011-11-22 18:37:27 [-0600]:

>I presume that the drop is occuring in between the NET layer, and the sys
>call interface, do you agree?  Where should I begin looking?

perf script net_dropmonitor.py from Neil should do the job.

HGN
