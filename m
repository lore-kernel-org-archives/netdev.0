From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: [PATCH] s2io: netpoll support
Date: Thu, 22 Jun 2006 12:45:33 -0700
Message-ID: <001801c69634$6d3b33a0$4110100a@pc.s2io.com>
References: <4491A8B4.1050105@hp.com>
Reply-To: <ravinandan.arakali@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <jgarzik@pobox.com>,
	"'Ananda. Raju \(E-mail\)'" <ananda.raju@neterion.com>,
	"'Leonid. Grossman \(E-mail\)'" <leonid.grossman@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:47765 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S1751057AbWFXALR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 20:11:17 -0400
To: "'Brian Haley'" <brian.haley@hp.com>, <netdev@vger.kernel.org>
In-Reply-To: <4491A8B4.1050105@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since the poll_controller entry point will be used by utilities such as
netdump, I am thinking we need to clear Tx interrupts as well here.
Did you get a chance to test this patch with netdump ?

Thanks,
Ravi

-----Original Message-----
From: Brian Haley [mailto:brian.haley@hp.com]
Sent: Thursday, June 15, 2006 11:37 AM
To: netdev@vger.kernel.org
Cc: ravinandan.arakali@neterion.com; jgarzik@pobox.com; Ananda. Raju
(E-mail); Leonid. Grossman (E-mail)
Subject: Re: [PATCH] s2io: netpoll support


This adds netpoll support for things like netconsole/kgdboe to the s2io
10GbE driver.

Signed-off-by: Brian Haley <brian.haley@hp.com>

