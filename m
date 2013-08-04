From: Santiago Garcia Mantinan <manty@manty.net>
Subject: Re: bonding + arp monitoring fails if interface is a vlan
Date: Sun, 4 Aug 2013 12:45:43 +0200
Message-ID: <CAJk_L2FJyD2X7EPztiVWLBD4NDR_VOehdFEeV+nq7a+sO9+_wA@mail.gmail.com>
References: <20130801121142.GA444@www.manty.net>
	<51FB9EE5.3040907@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f48.google.com ([209.85.128.48]:52622 "EHLO
	mail-qe0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025Ab3HDKpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Aug 2013 06:45:44 -0400
Received: by mail-qe0-f48.google.com with SMTP id 9so1180991qea.7
        for <netdev@vger.kernel.org>; Sun, 04 Aug 2013 03:45:44 -0700 (PDT)
In-Reply-To: <51FB9EE5.3040907@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/8/2 Nikolay Aleksandrov <nikolay@redhat.com>:
> I believe that it is because dev_trans_start() returns 0 for 8021q devices and
> so the calculations if the slave has transmitted are wrong, and the flip-flop
> happens.
> Please try the attached patch, it should resolve your issue (basically it gets
> the dev_trans_start of the vlan's underlying device if a vlan is found).

Thanks, patched and compiling, I'll try today with my laptops and
tomorrow at the lab I had setup and then at the original machine.

I'll let you know how things go.

Regards.
-- 
Manty/BestiaTester -> http://manty.net
