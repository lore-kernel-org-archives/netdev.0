From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6.17 2/9] NetXen: Hardware access routines
Date: Mon, 21 Aug 2006 07:03:02 -0700
Message-ID: <20060821070302.5666e1ab@localhost.localdomain>
References: <Pine.LNX.4.64.0608180713480.6875@dut39>
	<Pine.LNX.4.64.0608180746090.6875@dut39>
	<20060818081659.7c515bbf@dxpl.pdx.osdl.net>
	<200608211357.23600.amitkale@linsyssoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Amit S. Kale" <amitkale@netxen.com>, netdev@vger.kernel.org,
	jeff@garzik.org, sanjeev@netxen.com, unmproj@linsyssoft.com,
	rob@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:33425 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030452AbWHUODZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2006 10:03:25 -0400
To: "Amit S. Kale" <amitkale@linsyssoft.com>
In-Reply-To: <200608211357.23600.amitkale@linsyssoft.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Aug 2006 13:57:23 +0530
"Amit S. Kale" <amitkale@linsyssoft.com> wrote:

> We can certainly create a table for all error messages. It'll hurt readability 
> of code in many of the other places where printks are used to indicate some 
> hardware error.
> -Amit

My suggestion was intended as an way to handle multiple driver versions
all using the same firmware or vice versa. By locking the firmware and
driver version together you might make maintenance more difficult.
