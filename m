From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Tue, 13 May 2008 08:50:59 -0700
Message-ID: <OFDBD6E282.6F00998A-ON88257448.0056D40D-88257448.0057105E@us.ibm.com>
References: <20080513093718.GA24185@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: acme@redhat.com, David Miller <davem@davemloft.net>,
	dccp@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:38530 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754044AbYEMPvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 11:51:03 -0400
In-Reply-To: <20080513093718.GA24185@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Are they mutually exclusive?

Why not add SOCK_DGRAM/IPPROTO_DCCP support while leaving
the existing stuff alone, and then requiring programs that want to use
getaddrinfo to use it that way?

                                                +-DLS

