From: Stefan Assmann <sassmann@redhat.com>
Subject: Re: [PATCH] e1000e: Fix usage under kexec
Date: Tue, 17 Nov 2009 10:21:40 +0100
Message-ID: <4B026B24.5040108@redhat.com>
References: <4AF87AB1.1070603@anduras.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Sven Anders <sven@anduras.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30001 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752674AbZKQJVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2009 04:21:41 -0500
In-Reply-To: <4AF87AB1.1070603@anduras.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09.11.2009 21:25, Sven Anders wrote:
> Hello!
> 
> We're experiencing the following problem:
> 
> We start a minimal linux system, prepare the system and start the
> final system via kexec.
> On two different systems (one with a 82573 and one with a 82574),
> the driver cannot initialize the network hardware, because the PHY
> is not recognized.
> 
> We get the following error:
>   e1000e: probe of 0000:02:00.0 failed with error -2

Hi Sven,

have a look at the following thread, it seems very similar.
http://kerneltrap.org/mailarchive/linux-netdev/2009/3/7/5114394

  Stefan
--
Stefan Assmann         | Red Hat GmbH
Software Engineer      | Otto-Hahn-Strasse 20, 85609 Dornach
                       | HR: Amtsgericht Muenchen HRB 153243
                       | GF: Brendan Lane, Charlie Peters,
sassmann at redhat.com |     Michael Cunningham, Charles Cachera
