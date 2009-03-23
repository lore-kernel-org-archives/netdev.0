From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: Use request_firmware()
Date: Mon, 23 Mar 2009 16:28:51 -0700
Message-ID: <1237850931.18617.39.camel@HP1>
References: <1237501747.4126.10.camel@deadeye.i.decadent.org.uk>
 <1237503884.16140.23.camel@HP1>
 <20090319232541.GA19262@wavehammer.waldi.eu.org>
 <20090320.155030.164080684.davem@davemloft.net>
 <1237844879.18617.20.camel@HP1>
 <20090323223238.GB29609@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"davem@davemloft.org" <davem@davemloft.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Bastian Blank" <waldi@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4826 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752457AbZCWXeN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2009 19:34:13 -0400
In-Reply-To: <20090323223238.GB29609@wavehammer.waldi.eu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2009-03-23 at 15:32 -0700, Bastian Blank wrote:
> On Mon, Mar 23, 2009 at 02:47:59PM -0700, Michael Chan wrote:
> > I'd also like to add the version information to the
> bnx2_fw_file_entry
> > struct instead of embedding it in the file name.  It is more
> flexible
> > this way as each section can have different versions and can be
> updated
> > separately.
> 
> Only if the firmwares are compatible enough. Can I pull the firmwares
> from a
> 2.6.21 kernel and ask a .29 to use them? One argument was always that
> the firmware is coupled with the code.

No, this won't work.  Please see new proposal to breakup firmware into
multiple files.


