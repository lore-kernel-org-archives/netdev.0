From: Todd Showalter <tshowalter@silverbirchstudios.com>
Subject: Re: Problems with sky2 driver.
Date: Mon, 24 Jul 2006 15:11:42 -0400
Message-ID: <20060724151142.7c4ae4ad@akemi>
References: <20060724133829.49bf7979@akemi>
	<20060724105303.2c4d529f@localhost.localdomain>
	<20060724143839.56bfebdb@akemi>
	<20060724114533.2c61992b@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.silverbirchstudios.com ([207.176.159.130]:56802 "EHLO mail")
	by vger.kernel.org with ESMTP id S1751280AbWGXTLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 15:11:50 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060724114533.2c61992b@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 24 Jul 2006 11:45:33 -0700, Stephen Hemminger
<shemminger@osdl.org> wrote:

> I suspect that probably isn't a sky2 driver problem.
> Does it go away if you turn of TCP window scaling:
> 	sysctl -w net.ipv4.tcp_window_scaling=0
> 
> If so, you probably have a middlebox in your path that is not
> correctly handling TCP window scaling. OpenBSD seems to be
> particularly bad.

    This seems to be the case.  The combination of the patch and
shutting off tcp window scaling seems to have fixed the box.  Thanks!

    I'll ask around locally about network structure.

                                               Todd.

--
  Todd Showalter
  Silverbirch Studios
