From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Bugme-new] [Bug 7254] New: leaving IP multicast group with incorrect
 imr_address unexpectedly succeeded
Date: Tue, 3 Oct 2006 11:33:07 -0700
Message-ID: <OF6602D35D.A9238CC7-ON882571FC.00659110-882571FC.0065E706@us.ibm.com>
References: <20061003100750.902d4837.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Alexandra.Kossovsky@oktetlabs.ru,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, Konstantin.Petrov@oktetlabs.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:8124 "EHLO e31.co.us.ibm.com")
	by vger.kernel.org with ESMTP id S1030459AbWJCSdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2006 14:33:07 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k93IX6kh028344
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 14:33:06 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k93IX6Km541452
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 12:33:06 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k93IX52W019494
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 12:33:05 -0600
In-Reply-To: <20061003100750.902d4837.akpm@osdl.org>
To: Andrew Morton <akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the index is set, it doesn't look up the address (which may be 
expensive).
If you want to look up by address, the index must be 0.

I wouldn't  call that a bug.

                                        +-DLS

