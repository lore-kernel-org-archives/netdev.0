From: TuxOholic <tuxoholic@hotmail.de>
Subject: Re: Network Receive Problems on NetGearRn104 Armarda370
Date: Wed, 23 Sep 2015 19:01:39 +0200
Message-ID: <BLU436-SMTP1300DC4BE257863BB775B24D8440@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from blu004-omc1s10.hotmail.com ([65.55.116.21]:56978 "EHLO
	BLU004-OMC1S10.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753254AbbIWRJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 13:09:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi list,
Hello Thomas,

Follow up to [1] from March 2015:

Using a Readynas 102 with mainline kernel 4.2 I still see a bunch of
error messages in dmesg during network transfer:

mvneta d0074000.ethernet eth0: bad rx status 0f830000 (overrun error),
size=1008
mvneta d0074000.ethernet eth0: bad rx status 0f830000 (overrun error),
size=440

The amount of errors have decreased a lot from hundreds in natisbad
kernel 4.0.5 (flooding syslog) down to just a few in my own build of
mainline 4.2. kernel config I used was config-4.0.5.rn102 from [2] ,
mvneta is built into kernel (not module). eth0 link is up continuous at
1000 MB/s , I never see dropped links while these errors occur.

My home LAN consists of gigabit cables (cat 5) and gigabit switches. I
never encounter internal transmission errors other than those with the
RN102 marvell driver.

As Michael Langer has mentioned in [1], 3.17 of natisbad was not
affected, I confirmed that with the same kernel image from [2].

System OS in use is Debian/Jessie, original Marvell u-boot from nand
(September 2013)

Any patches/ideas I could try to get rid of transmission errors completely?

[1] https://www.marc.info/?l=linux-netdev&m=142573659929563
[2] http://natisbad.org/nas-kernels/
