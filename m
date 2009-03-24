From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: Use request_firmware()
Date: Mon, 23 Mar 2009 18:11:25 -0700
Message-ID: <1237857085.18617.47.camel@HP1>
References: <1237501747.4126.10.camel@deadeye.i.decadent.org.uk>
 <1237503884.16140.23.camel@HP1>
 <20090319232541.GA19262@wavehammer.waldi.eu.org>
 <20090320.155030.164080684.davem@davemloft.net>
 <1237844879.18617.20.camel@HP1>
 <20090323222915.GA29609@wavehammer.waldi.eu.org>
 <1237850656.18617.34.camel@HP1> <49C825EC.50100@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Bastian Blank" <waldi@debian.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2376 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753563AbZCXBQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2009 21:16:40 -0400
In-Reply-To: <49C825EC.50100@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2009-03-23 at 17:14 -0700, Rick Jones wrote:
> Michael Chan wrote:
> > May be I'll break up each firmware section into a
> > different file and the file name will be updated with each version.
> > This will allow different sections to be updated separately and older
> > kernels will still have access to the older firmware.
> 
> Is that really necessary?  It is enough "fun" finding just the one firmware file 
> as it is.

If all the firmware sections are in the same file, much of the firmware
file will be duplicated in a new file when we update just one section.


