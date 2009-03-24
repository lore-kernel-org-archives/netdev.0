From: Bastian Blank <waldi@debian.org>
Subject: Re: [PATCH] bnx2: Use request_firmware()
Date: Tue, 24 Mar 2009 08:42:14 +0100
Message-ID: <20090324074213.GA4576@wavehammer.waldi.eu.org>
References: <1237501747.4126.10.camel@deadeye.i.decadent.org.uk> <1237503884.16140.23.camel@HP1> <20090319232541.GA19262@wavehammer.waldi.eu.org> <20090320.155030.164080684.davem@davemloft.net> <1237844879.18617.20.camel@HP1> <20090323222915.GA29609@wavehammer.waldi.eu.org> <1237850656.18617.34.camel@HP1> <49C825EC.50100@hp.com> <1237857085.18617.47.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Rick Jones <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wavehammer.waldi.eu.org ([82.139.201.20]:34439 "EHLO
	wavehammer.waldi.eu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753706AbZCXHmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 03:42:17 -0400
Content-Disposition: inline
In-Reply-To: <1237857085.18617.47.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2009 at 06:11:25PM -0700, Michael Chan wrote:
> On Mon, 2009-03-23 at 17:14 -0700, Rick Jones wrote:
> > Michael Chan wrote:
> > > May be I'll break up each firmware section into a
> > > different file and the file name will be updated with each version.
> > > This will allow different sections to be updated separately and older
> > > kernels will still have access to the older firmware.
> > Is that really necessary?  It is enough "fun" finding just the one firmware file 
> > as it is.
> If all the firmware sections are in the same file, much of the firmware
> file will be duplicated in a new file when we update just one section.

What is the advantage of this? I always saw updates to more than one
firmware at once in the past. The question is not: is it possible, but:
it is necessary.

Bastian

-- 
Our way is peace.
		-- Septimus, the Son Worshiper, "Bread and Circuses",
		   stardate 4040.7.
