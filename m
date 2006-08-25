From: Sanjeev Jorapur <sanjeev@netxen.com>
Subject: Re: [PATCH 2.6.17 2/9] NetXen: Hardware access routines
Date: Fri, 25 Aug 2006 11:23:17 -0700
Message-ID: <1156530197.2916.24.camel@nbsanjeev>
References: <Pine.LNX.4.64.0608180713480.6875@dut39>
	 <Pine.LNX.4.64.0608180746090.6875@dut39>
	 <20060818081659.7c515bbf@dxpl.pdx.osdl.net>
	 <200608211357.23600.amitkale@linsyssoft.com>
	 <20060821070302.5666e1ab@localhost.localdomain>
Reply-To: sanjeev@netxen.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Amit S. Kale" <amitkale@linsyssoft.com>,
	"Amit S. Kale" <amitkale@netxen.com>, netdev@vger.kernel.org,
	jeff@garzik.org, unmproj@linsyssoft.com, rob@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:11317 "EHLO
	nxmail.netxen.com") by vger.kernel.org with ESMTP id S964879AbWHYSXq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 14:23:46 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060821070302.5666e1ab@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 2006-08-21 at 07:03 -0700, Stephen Hemminger wrote:
> On Mon, 21 Aug 2006 13:57:23 +0530
> "Amit S. Kale" <amitkale@linsyssoft.com> wrote:
> 
> > We can certainly create a table for all error messages. It'll hurt readability 
> > of code in many of the other places where printks are used to indicate some 
> > hardware error.
> > -Amit
> 
> My suggestion was intended as an way to handle multiple driver versions
> all using the same firmware or vice versa. By locking the firmware and
> driver version together you might make maintenance more difficult.

We misunderstood your earlier comment. The compatible driver & firmware
images have the same major & minor version numbers. Only the sub-version
numbers may be different. This gives us more flexibility in releasing
driver & firmware fixes.

Sanjeev.


