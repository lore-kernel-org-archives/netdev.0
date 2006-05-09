From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC PATCH 34/35] Add the Xen virtual network device driver.
Date: Tue, 09 May 2006 13:46:47 -0700
Message-ID: <ada1wv3apu0.fsf@cisco.com>
References: <20060509084945.373541000@sous-sol.org>
	<20060509085201.446830000@sous-sol.org>
	<20060509132556.76deaa91@localhost.localdomain>
	<6a1855ab01a195ac2a28a97c5f966f67@cl.cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	virtualization@lists.osdl.org, Ian Pratt <ian.pratt@xensource.com>,
	xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org,
	Chris Wright <chrisw@sous-sol.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:57504 "EHLO
	sj-iport-4.cisco.com") by vger.kernel.org with ESMTP
	id S1751168AbWEIUqy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 16:46:54 -0400
To: Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
In-Reply-To: <6a1855ab01a195ac2a28a97c5f966f67@cl.cam.ac.uk> (Keir Fraser's message of "Tue, 9 May 2006 21:26:11 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Keir> Where should we get our entropy from in a VM environment?
    Keir> Leaving the pool empty can cause processes to hang.

You could have something like a virtual HW RNG driver (with a frontend
and backend), which steals from the dom0 /dev/random pool.

 - R.
