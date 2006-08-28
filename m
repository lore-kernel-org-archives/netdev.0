From: "Amit S. Kale" <amitkale@linsyssoft.com>
Subject: Re: [PATCH 2.6.17 2/9] NetXen: Hardware access routines
Date: Mon, 28 Aug 2006 15:22:07 +0530
Message-ID: <200608281522.07674.amitkale@linsyssoft.com>
References: <Pine.LNX.4.64.0608180713480.6875@dut39> <200608211357.23600.amitkale@linsyssoft.com> <20060821070302.5666e1ab@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Amit S. Kale" <amitkale@netxen.com>, netdev@vger.kernel.org,
	jeff@garzik.org, sanjeev@netxen.com, unmproj@linsyssoft.com,
	rob@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:1190 "EHLO
	svr68.ehostpros.com") by vger.kernel.org with ESMTP id S932487AbWH1JwW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 05:52:22 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060821070302.5666e1ab@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 21 August 2006 19:33, Stephen Hemminger wrote:
> On Mon, 21 Aug 2006 13:57:23 +0530
>
> "Amit S. Kale" <amitkale@linsyssoft.com> wrote:
> > We can certainly create a table for all error messages. It'll hurt
> > readability of code in many of the other places where printks are used to
> > indicate some hardware error.
> > -Amit
>
> My suggestion was intended as an way to handle multiple driver versions
> all using the same firmware or vice versa. By locking the firmware and
> driver version together you might make maintenance more difficult.

Ah, I had missed that completely in your first email. Thanks for your 
suggestion.

The NetXen firmware will most probably keep changing. It's hardware is 
flexible enough, so the firmware changes will possibly be varied in nature. 
Thinking about this further, it seems we should coalesce firmware dependent 
code into a few isolated functions. While this may be difficult, we should do 
it anyway. Hopefully future changes will not cause these efforts to go waste.
-Amit

