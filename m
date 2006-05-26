From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/3] pci: bcm43xx avoid pci_find_device
Date: Fri, 26 May 2006 07:09:55 -0400
Message-ID: <4476E203.1080701@pobox.com>
References: <20060526001053.D2349C7C58@atrey.karlin.mff.cuni.cz> <44764D4B.6050105@pobox.com> <4476D63E.8090207@gmail.com> <4476D6EC.4060501@pobox.com> <4476D95B.5030601@gmail.com> <4476DA5C.9080602@pobox.com> <4476DE47.7010907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@suse.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org,
	mb@bu3sch.de, st3@riseup.net, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:31690 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751398AbWEZLKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 07:10:00 -0400
To: Jiri Slaby <jirislaby@gmail.com>
In-Reply-To: <4476DE47.7010907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Slaby wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Jeff Garzik napsal(a):
>> The point is that you don't need to loop over the table,
>> pci_match_one_device() does that for you.
> The problem is, that there is no such function, I think.
> If you take a look at pci_dev_present:

The function you want is pci_dev_present().

	Jeff



