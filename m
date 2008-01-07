From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: sunhme x86 SMP issues
Date: Tue, 08 Jan 2008 00:01:20 +0100
Message-ID: <4782AF40.8080200@gmail.com>
References: <477369C9.7030405@tsaousis.gr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Costa Tsaousis <costa@tsaousis.gr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.189]:41290 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752319AbYAGW5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 17:57:31 -0500
Received: by mu-out-0910.google.com with SMTP id w8so5183208mue.1
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2008 14:57:30 -0800 (PST)
In-Reply-To: <477369C9.7030405@tsaousis.gr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Costa Tsaousis wrote, On 12/27/2007 10:00 AM:

> Merry Christams,
> 
> I would like to report incompatibilities of the sunhme driver with x86 SMP.
> 


Hi Costa,

It seems your report has to wait for better times... I'm not driver's
expert, but maybe you could try some of these:

- since 'the list' seems to be busy now, opening a bug report at
bugzilla.kernel.org (copy most of these information and lspci -vvv)
looks like the best way to not forget about this,

- I'd a look at the code and it seems it uses quite coarse locking,
so it could be SMP unfriendly by design...; could you try with
kernel boot parameter: noirqbalance (or read about SMP issues e.g.
for another card Documentation/networking/cxgb.txt).

Regards,
Jarek P.
