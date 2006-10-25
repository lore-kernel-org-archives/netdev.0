From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 driver fails with on-board BCM95789 NICS (GigaByte
 GA-7VCSV)
Date: Wed, 25 Oct 2006 09:39:46 -0700
Message-ID: <1161794387.3613.3.camel@rh4>
References: <7744a2840610241432i42364aaap672f8eb5bf25c066@mail.gmail.com>
 <1551EAE59135BE47B544934E30FC4FC093FC6D@NT-IRVA-0751.brcm.ad.broadcom.com>
 <7744a2840610250602m4b589fedq3a4e89f26fc18794@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:23058 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1161364AbWJYQpa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 12:45:30 -0400
To: "Richard Bollinger" <rabollinger@gmail.com>
In-Reply-To: <7744a2840610250602m4b589fedq3a4e89f26fc18794@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-10-25 at 09:02 -0400, Richard Bollinger wrote:

> # ethtool -t eth2
> The test result is FAIL
> The test extra info:
> nvram test     (online)          0
> link test      (online)          1
> register test  (offline)         0
> memory test    (offline)         0
> loopback test  (offline)         0
> interrupt test (offline)         1
> 

This confirms that it's some kind of interrupt problem as David had
suggested, at least on eth2.  You can try booting with "noapic" to see
if it works if you haven't got the patch from Adrian Bunk yet.

