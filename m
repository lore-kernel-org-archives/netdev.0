From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: WARNING at local_bh_enable while tcp_retransmit
Date: Tue, 07 Dec 2010 21:56:19 +0100
Message-ID: <4CFE9F73.1040203@gmail.com>
References: <20101207182308.664e171d.isloginov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Ilya Loginov <isloginov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36950 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136Ab0LGU4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 15:56:25 -0500
Received: by wwa36 with SMTP id 36so369387wwa.1
        for <netdev@vger.kernel.org>; Tue, 07 Dec 2010 12:56:24 -0800 (PST)
In-Reply-To: <20101207182308.664e171d.isloginov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilya Loginov wrote:
> 	Hi, I am working on some network drivers.
...
> 	I watched bonding, but I could not realize why it didn't get
> same warning. It use very similar scheme of work.
> 
> 	Do you have any ideas?

Hi, isn't any of your drivers disabling irqs on this path?
(If no, what is the kernel version?)

Jarek P.
