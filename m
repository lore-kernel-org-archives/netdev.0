From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: SCTP control socket question
Date: Thu, 27 Mar 2008 08:48:20 -0400
Message-ID: <47EB9794.7010407@hp.com>
References: <1206619433.32459.9.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev List <netdev@vger.kernel.org>,
	lksctp-developers@lists.sourceforge.net
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:13528 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484AbYC0MsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 08:48:25 -0400
In-Reply-To: <1206619433.32459.9.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis V. Lunev wrote:
> Hello, Vlad!
> 
> I have read SCTP sources and found that SCTP control socket
> (sctp_ctl_socket) remains hashed unlike similar staff in UDP/TCP etc.
> 
> Am I wrong, that it should not be hashed or not?

Why do you believe that the socket is hashed?  That socket is only
allocated and referenced.  It's should not be in any hash tables
since we hold a global reference on it.

-vlad
