From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: PROBLEM: A set of networking related oopses
Date: Sat, 08 Mar 2008 10:53:05 +0100
Message-ID: <47D26201.2060201@gmail.com>
References: <D04F01C2-03F0-4FBC-933D-62899456BEE9@solitudo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tuomas Jormola <tj@solitudo.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.187]:4250 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbYCHJsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2008 04:48:13 -0500
Received: by fk-out-0910.google.com with SMTP id z23so698200fkz.5
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2008 01:48:11 -0800 (PST)
In-Reply-To: <D04F01C2-03F0-4FBC-933D-62899456BEE9@solitudo.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tuomas Jormola wrote, On 03/06/2008 08:05 PM:

> Hello,

Hi,

> [1.] One line summary of the problem:
> My gateway machine is suffering from kernel oopses that don't kill the  
> machine, but do occur every now and then

Do you have irq balancing enabled for your eths (are eth interrupts shown
for more than one cpu in /proc/interrupts)? If so, try to disable this.

This link could be helpful:

http://marc.info/?l=linux-netdev&m=120349568512423&w=2

Regards,
Jarek P.
