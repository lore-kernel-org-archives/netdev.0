From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Ping Is Broken
Date: Tue, 13 Oct 2009 05:10:19 +0000
Message-ID: <20091013051019.GA6159@ff.dom.local>
References: <7e84ed60910090316ne9224fat81d9c79c58fc713b@mail.gmail.com> <7e84ed60910090934y2a0d422cr158aa8d15e452f97@mail.gmail.com> <7e84ed60910090944q5c66ea0w63ed55a72482bf2f@mail.gmail.com> <4AD39342.7090209@hp.com> <4AD3A388.7020709@gmail.com> <4AD3BC12.6020409@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob.Townley@gmail.com, netdev@vger.kernel.org,
	Omaha Linux User Group <olug@olug.org>,
	CentOS mailing list <centos@centos.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:65304 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751551AbZJMFLC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 01:11:02 -0400
Received: by fxm27 with SMTP id 27so9828890fxm.17
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2009 22:10:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4AD3BC12.6020409@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 12, 2009 at 07:30:26PM -0400, Brian Haley wrote:
> 
> 
> Jarek Poplawski wrote:
> > Brian Haley wrote, On 10/12/2009 10:36 PM:
> > 
> >> In this case ping is doing an SO_BINDTODEVICE to eth0, so the kernel is going
> >> to force the packets out of it, even if it isn't the "correct" interface.  If
> >> you ran tcpdump you'd probably see an ARP resolution failure, or an ICMP from
> >> a gateway.
> > 
> > BTW, SO_BINDTODEVICE is used only to acquire a source address, not the real
> > connection (unless I miss something).
> 
> No, SO_BINDTODEVICE affects routing, as well as incoming packets - it's in macros
> like INET_MATCH(), from what I've seen it restricts a socket to only use the device
> specified, irregardless of the source address you're using.  For example, you can
> bind to 127.0.0.1 and send packets out eth0 if sk_bound_dev_if is set to it if I
> remember correctly.

I've commented your: "In this case ping is doing an SO_BINDTODEVICE to eth0",
so meant: SO_BINDTODEVICE is used *by ping* only to acquire a source address.

Jarek P.
