From: Christoph Raisch <RAISCH@de.ibm.com>
Subject: Re: EHEA: Is there a size limit below 80K for patches?
Date: Thu, 8 Jun 2006 14:17:56 +0200
Message-ID: <OF56CA8BB9.67AC7182-ONC1257187.003F6F35-C1257187.00430AFF@de.ibm.com>
References: <44880B4C.3020403@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Heiko J Schick <schickhj@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>, ossthema@de.ibm.com,
	Thomas OS Klein <osstklei@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:24734 "EHLO
	mtagate1.de.ibm.com") by vger.kernel.org with ESMTP id S964818AbWFHMP7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jun 2006 08:15:59 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.6/8.13.6) with ESMTP id k58CFwvB146286
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 8 Jun 2006 12:15:58 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k58CHvSd106398
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 8 Jun 2006 14:17:57 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k58CFv0m013436
	for <netdev@vger.kernel.org>; Thu, 8 Jun 2006 14:15:57 +0200
In-Reply-To: <44880B4C.3020403@garzik.org>
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

well, now I'm confused...
2 People, two opinions....


Here's a URL for a complete tarball, "sharing" the download location with
our other driver.
http://prdownloads.sourceforge.net/ibmehcad/ehea_EHEA_0002.tgz

We're waiting for a sourceforge project now since 9 days to put out a tgz,
and it looks like many other people get upset right now by their response
time.

So what's the "right"/preferred way to proceed?


Christop R.

> We're currently developing a new Ethernet device driver for a 10G IBM
chip
> for System p. (ppc64)
>
> A later version of the driver should end up in mainline kernel.
> How should we proceed to get first comments by the community?
> Either post this code as a patch to netdev or
yes

> put a full tarball on for example sourceforge?
nope.

Please read and observe:  Documentation/SubmittingPatches
and Section 3 of it, References, for other sources of
expectations/requirements.

The -mm tree also contains Documentation/SubmitChecklist
that you may find useful.

---
~Randy



Jeff Garzik <jeff@xxxxx> wrote on 08.06.2006 13:34:36:

> Jan-Bernd Themann wrote:
> > Hello,
> >
> > we tried two times to send a patch set. In both cases the second
> > (largest) patch
> > got lost. The first one was a bit above 100k, the second one we tried
> > was like 75K.
> >
> > Any idea what might be the problem?
>
> It might be size, or tripping a spam filter.
>
> For a new driver, do the sane thing and just post a URL.
>
>    Jeff
>
>
>

