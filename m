From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: arcnet: protocol is buggy messages in 3.0 kernel, not in 2.33 kernel
Date: Fri, 4 May 2012 01:23:52 +0200
Message-ID: <20120503232352.GA3850@electric-eye.fr.zoreil.com>
References: <CAJDhSdc5J1xzvxYhvru6kjqAbq1NAtvWQCu-tXbi4aE_NXGXrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Rob Janssen <rob.janssen76@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48533 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756403Ab2ECX3s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 19:29:48 -0400
Content-Disposition: inline
In-Reply-To: <CAJDhSdc5J1xzvxYhvru6kjqAbq1NAtvWQCu-tXbi4aE_NXGXrg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rob Janssen <rob.janssen76@gmail.com> :
[...]
> Does anyone have what causes this message in the 3.0 kernel and/or how
> to fix this ?

Wild guess: hard_header_len is sizeof(struct archdr). archdr embeds a huge
ethhdr but the header build helper only accounts for ARC_HDR_SIZE +
RFC1201_HDR_SIZE.

-- 
Ueimor
