From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [PATCH] e1000e: Add new ID
Date: Tue, 10 Nov 2009 10:56:33 -0800
Message-ID: <8DD2590731AB5D4C9DBF71A877482A903DB7F8F9@orsmsx509.amr.corp.intel.com>
References: <4AF87AAF.2020508@anduras.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Sven Anders <sven@anduras.de>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20985 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757657AbZKJS43 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 13:56:29 -0500
In-Reply-To: <4AF87AAF.2020508@anduras.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NAK.  While this is indeed a trivial patch to enable a device that is not currently supported in e1000e, this device requires special handling to get the bypass functionality to work properly and as such this patch is insufficient.

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>On Behalf Of Sven Anders
>Sent: Monday, November 09, 2009 12:25 PM
>To: netdev
>Subject: [PATCH] e1000e: Add new ID
>
>Hello!
>
>We use the the 82571EB (QUAD COPPER BP) with the e1000e driver.
>We haven't experienced any problems yet.
>
>The patch is trivial, just adding a new PCI ID...
>
>Regards
> Sven Anders
>
>--
> Sven Anders <anders@anduras.de>                 () Ascii Ribbon Campaign
>                                                 /\ Support plain text e-
>mail
> ANDURAS service solutions AG
> Innstrasse 71 - 94036 Passau - Germany
> Web: www.anduras.de - Tel: +49 (0)851-4 90 50-0 - Fax: +49 (0)851-4 90
>50-55
>
>Those who would give up essential Liberty, to purchase a little
>temporary Safety, deserve neither Liberty nor Safety.
>  - Benjamin Franklin
