From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Tigon3 crash when used with any torrent app
Date: Tue, 10 Oct 2006 19:52:06 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC093FBFF@NT-IRVA-0751.brcm.ad.broadcom.com>
References: <200610102230.23700.sas@noend.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:23304 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S932425AbWJKCwX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 22:52:23 -0400
Content-class: urn:content-classes:message
In-Reply-To: <200610102230.23700.sas@noend.com>
To: "Sebastian Alfredo Salvino" <sas@noend.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sebastian Alfredo Salvino wrote:

> However when I am booted up into 2.6.18 and try to connect to 
> any p2p network 
> via BitTorrent, KTorrent, etc., it just hang. 
> 

Did the same setup work in 2.6.17?  If yes, can you bisect
the tg3 patches between 2.6.17 and 2.6.18?

Looking at the patches between 2.6.17 and 2.6.18, nothing
really jumps out, especially if you have already tried
turning off TSO.

