From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Problems with tg3 on BCM5720
Date: Wed, 26 Sep 2012 14:40:02 -0700
Message-ID: <1348695602.7220.91.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <CAKmKYaCBG5hURNomffgp9gRhS7g2BYsNG-LTmBrKsX-iyVzVxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Dirkjan Ochtman" <dirkjan@ochtman.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1130 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751116Ab2IZVkS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2012 17:40:18 -0400
In-Reply-To: <CAKmKYaCBG5hURNomffgp9gRhS7g2BYsNG-LTmBrKsX-iyVzVxg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-26 at 15:48 +0200, Dirkjan Ochtman wrote:
> I've also run some tests with ethtool:
> 
> djc@jansky ~ $ sudo ethtool --test eth0
> The test result is FAIL
> The test extra info:
> nvram test        (online)       0
> link test         (online)       1
> register test     (offline)      0
> memory test       (offline)      0
> mac loopback test (offline)      7
> phy loopback test (offline)      7
> ext loopback test (offline)      0
> interrupt test    (offline)      1

It is most likely that the device eth0 is down.  The device needs to be
up in order to perform all the tests that failed.  Please bring up the
device and run the test again.  Thanks.
> 
> 
