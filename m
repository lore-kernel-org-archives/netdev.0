From: Bastian Blank <waldi@debian.org>
Subject: Re: [PATCH] bnx2: Use request_firmware()
Date: Mon, 23 Mar 2009 23:32:38 +0100
Message-ID: <20090323223238.GB29609@wavehammer.waldi.eu.org>
References: <1237501747.4126.10.camel@deadeye.i.decadent.org.uk> <1237503884.16140.23.camel@HP1> <20090319232541.GA19262@wavehammer.waldi.eu.org> <20090320.155030.164080684.davem@davemloft.net> <1237844879.18617.20.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"davem@davemloft.org" <davem@davemloft.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wavehammer.waldi.eu.org ([82.139.201.20]:49036 "EHLO
	wavehammer.waldi.eu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754059AbZCWWcl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 18:32:41 -0400
Content-Disposition: inline
In-Reply-To: <1237844879.18617.20.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2009 at 02:47:59PM -0700, Michael Chan wrote:
> I'd also like to add the version information to the bnx2_fw_file_entry
> struct instead of embedding it in the file name.  It is more flexible
> this way as each section can have different versions and can be updated
> separately.

Only if the firmwares are compatible enough. Can I pull the firmwares from a
2.6.21 kernel and ask a .29 to use them? One argument was always that
the firmware is coupled with the code.

Bastian

-- 
Worlds are conquered, galaxies destroyed -- but a woman is always a woman.
		-- Kirk, "The Conscience of the King", stardate 2818.9
