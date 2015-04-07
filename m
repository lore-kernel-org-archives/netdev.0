From: Michael Chan <mchan@broadcom.com>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen
Date: Tue, 7 Apr 2015 09:55:40 -0700
Message-ID: <1428425741.4212.1.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <21795.62414.465476.464027@mariner.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>,
	<xen-devel@lists.xensource.com>, <netdev@vger.kernel.org>
To: Ian Jackson <Ian.Jackson@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:6262 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753636AbbDGQzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 12:55:44 -0400
In-Reply-To: <21795.62414.465476.464027@mariner.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-04-07 at 16:12 +0100, Ian Jackson wrote:
> The symptom is a very high level of packet loss: around 25-30% (as
> seen in `ping').  There don't seem to be any untoward-looking kernel
> messages.  The lost packets get added to the `errors' counter shown in
> ifconfig. 

Please provide the output of "ethtool -S" which has a better breakdown
of the error counters.  Thanks.
