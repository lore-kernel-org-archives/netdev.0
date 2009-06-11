From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: TG3 kernel hard lockup with 2.6.30
Date: Thu, 11 Jun 2009 19:56:33 -0300
Message-ID: <1me8g6-fcd.ln1@tux.abusar.org.br>
References: <455ea5df0906111507t70e9a3fawbcd0da93ef3bb6e6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:46008 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755068AbZFKW44 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 18:56:56 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1MEtCa-0007Xp-R4
	for netdev@vger.kernel.org; Thu, 11 Jun 2009 22:56:56 +0000
Received: from c9345450.virtua.com.br ([201.52.84.80])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 22:56:56 +0000
Received: from fragabr by c9345450.virtua.com.br with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 22:56:56 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Jun 2009 18:07:30 -0400
Web Visum <webvisum@googlemail.com> wrote:

> I've tried turning off TSO via ethtool and that *appears* to delay the
> onset of the lockup, but it does not prevent it entirely.

ethtool --offload eth0 gso off

	Does it help? Or "sg off" or both?

-- 
Linux 2.6.30: Man-Eating Seals of Antiquity


