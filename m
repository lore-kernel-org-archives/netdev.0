From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3] 3c59x: fix PCI resource management
Date: Sun, 12 May 2013 19:18:03 +0400
Message-ID: <518FB2AB.5050706@cogentembedded.com>
References: <201305100114.08149.sergei.shtylyov@cogentembedded.com> <20130511.174027.2189352473297054848.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:45099 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753311Ab3ELPSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 May 2013 11:18:09 -0400
Received: by mail-lb0-f177.google.com with SMTP id 13so5607791lba.36
        for <netdev@vger.kernel.org>; Sun, 12 May 2013 08:18:08 -0700 (PDT)
In-Reply-To: <20130511.174027.2189352473297054848.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12-05-2013 4:40, David Miller wrote:

>> From: Sergei Shtylyov <sshtylyov@ru.mvista.com>

>> The driver wrongly claimed I/O ports at an address returned by pci_iomap() --
>> even if it was passed an MMIO address.  Fix this by claiming/releasing all PCI
>> resources in the PCI driver's probe()/remove() methods instead and get rid of
>> 'must_free_region' flag weirdness (why would Cardbus claim anything for us?).

>> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

> Applied, thanks.

    Thank you. Will you also queue this for -stable?

WBR, Sergei
