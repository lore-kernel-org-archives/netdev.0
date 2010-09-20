From: Alasdair G Kergon <agk@redhat.com>
Subject: Re: [dm-devel] idr_get_new_exact ?
Date: Mon, 20 Sep 2010 22:38:25 +0100
Message-ID: <20100920213825.GF30622@agk-dp.fab.redhat.com>
References: <AANLkTi=ZLupVyFR0e2v-TLpeNWdw1bVMZUAhgyxLJ7OV@mail.gmail.com> <adaiq20f90h.fsf@cisco.com> <4C97D197.9070703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: device-mapper development <dm-devel@redhat.com>,
	Roland Dreier <rdreier@cisco.com>,
	Ohad Ben-Cohen <ohad@wizery.com>, akpm@linux-foundation.org,
	Steve Wise <swise@chelsio.com>, linux-
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60358 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753440Ab0ITVj5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Sep 2010 17:39:57 -0400
Content-Disposition: inline
In-Reply-To: <4C97D197.9070703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 20, 2010 at 11:26:47PM +0200, Tejun Heo wrote:
> I agree.  Wouldn't those users better off simply using radix tree?
 
Can't speak for the other users, but dm uses it both ways - normally
happy with any id (minor number), but sometimes user requires a specific
one.

Alasdair

