From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [d80211] connecting to B-mode AP
Date: Thu, 14 Sep 2006 17:20:28 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F01785286@dhost002-46.dex002.intermedia.net>
References: <4509E4BE.40001@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:25994 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S932171AbWIOAU0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2006 20:20:26 -0400
Content-class: urn:content-classes:message
in-reply-to: <4509E4BE.40001@linux.intel.com>
To: "mabbas" <mabbas@linux.intel.com>, <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Why is it necessary to set phymode to B? - a G client can connect
perfectly well to a B AP.

Simon 

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of mabbas
Sent: Thursday, September 14, 2006 4:25 PM
To: netdev@vger.kernel.org
Subject: [d80211] connecting to B-mode AP

When I connect to b-mode only AP and then run iwconf it shows it as a
G-mode AP. I guess when we set frequency it look through all the modes
and set the mode to the first channel it founds. since B and G share the
same frequencies it will set phymode to G. How can we force it to set
phymode to the AP we are associating with.
-
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
