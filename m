From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: bonding directly changes underlying device address
Date: Tue, 13 May 2014 20:38:01 +0300
Message-ID: <CAJZOPZ+pOBw4M-ZFF2qsqNgGJcKcRRdhWFf4dy1FQ8Ngr-ZqRA@mail.gmail.com>
References: <5371FCD0.7050502@mellanox.com>
	<20140513115527.GC2910@minipsycho.orion>
	<20030.1399998641@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Or Gerlitz <ogerlitz@mellanox.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	netdev <netdev@vger.kernel.org>,
	Noa Osherovich <noaos@mellanox.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:40427 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753555AbaEMRiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 13:38:02 -0400
Received: by mail-qc0-f175.google.com with SMTP id w7so862620qcr.20
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 10:38:01 -0700 (PDT)
In-Reply-To: <20030.1399998641@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 13, 2014 at 7:30 PM, Jay Vosburgh
<jay.vosburgh@canonical.com> wrote:
>>Tue, May 13, 2014 at 01:06:56PM CEST, ogerlitz@mellanox.com wrote:

[...]

>>>I suspect this can lead to funny (or actually sad) bugs in networking
>>>drivers, can we avoid that?

>         Changing this would also remove support for the tlb mode from
> any device that cannot change their MAC while open.  I don't know how
> many devices that is (it's probably a small number nowadays), but if
> it's not zero then an assessment on losing that support has to be made.

Focusing on the last part of your reply, are you OK with a patch that
branches on whether that device supports ndo_set_mac_address and if
this is the case we will call dev_set_mac_address, else do the current
practice of setting dev_addr directly?

Or.
