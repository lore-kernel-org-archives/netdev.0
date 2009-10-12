From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Ping Is Broken
Date: Mon, 12 Oct 2009 23:45:44 +0200
Message-ID: <4AD3A388.7020709@gmail.com>
References: <7e84ed60910090316ne9224fat81d9c79c58fc713b@mail.gmail.com>	 <7e84ed60910090934y2a0d422cr158aa8d15e452f97@mail.gmail.com> <7e84ed60910090944q5c66ea0w63ed55a72482bf2f@mail.gmail.com> <4AD39342.7090209@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Rob.Townley@gmail.com, netdev@vger.kernel.org,
	Omaha Linux User Group <olug@olug.org>,
	CentOS mailing list <centos@centos.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:56635 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933257AbZJLVqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 17:46:24 -0400
Received: by fxm27 with SMTP id 27so9655735fxm.17
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2009 14:45:47 -0700 (PDT)
In-Reply-To: <4AD39342.7090209@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley wrote, On 10/12/2009 10:36 PM:

> 
> In this case ping is doing an SO_BINDTODEVICE to eth0, so the kernel is going
> to force the packets out of it, even if it isn't the "correct" interface.  If
> you ran tcpdump you'd probably see an ARP resolution failure, or an ICMP from
> a gateway.

BTW, SO_BINDTODEVICE is used only to acquire a source address, not the real
connection (unless I miss something).

Jarek P.
