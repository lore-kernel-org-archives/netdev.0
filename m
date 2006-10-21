From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH 2/3] netpoll: rework skb transmit queue
Date: Sat, 21 Oct 2006 01:00:16 -0400
Message-ID: <20061021050016.GD21948@redhat.com>
References: <20061020081857.743b5eb7@localhost.localdomain> <20061020.122427.55507415.davem@davemloft.net> <20061020122527.56292b56@dxpl.pdx.osdl.net> <20061020.125226.59656580.davem@davemloft.net> <20061020132532.65a3e655@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:29375 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751724AbWJUFA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2006 01:00:29 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061020132532.65a3e655@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 20, 2006 at 01:25:32PM -0700, Stephen Hemminger wrote:
 > On Fri, 20 Oct 2006 12:52:26 -0700 (PDT)
 > David Miller <davem@davemloft.net> wrote:
 > 
 > > From: Stephen Hemminger <shemminger@osdl.org>
 > > Date: Fri, 20 Oct 2006 12:25:27 -0700
 > > 
 > > > Sorry, but why should we treat out-of-tree vendor code any
 > > > differently than out-of-tree other code.
 > > 
 > > I think what netdump was trying to do, provide a way to
 > > requeue instead of fully drop the SKB, is quite reasonable.
 > > Don't you think?
 > 
 > 
 > Netdump doesn't even exist in the current Fedora source rpm.
 > I think Dave dropped it.

Indeed. Practically no-one cared about it, so it bit-rotted
really fast after we shipped RHEL4.  That, along with the focus
shifting to making kdump work seemed to kill it off over the last
12 months.

	Dave

-- 
http://www.codemonkey.org.uk
