From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC PATCH net-next 0/9] netlink: strict attribute checking
 option
Date: Fri, 16 Oct 2015 10:09:25 +0200
Message-ID: <20151016080925.GA9714@pox.localdomain>
References: <cover.1444926905.git.jbenc@redhat.com>
 <20151015.235007.973370825335101214.davem@davemloft.net>
 <20151016093945.54a6a7aa@griffin>
 <20151016.010644.2090038835491896678.davem@davemloft.net>
 <20151016100221.6fd5034f@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:35079 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752762AbbJPIJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 04:09:27 -0400
Received: by lbbes7 with SMTP id es7so4341697lbb.2
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 01:09:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20151016100221.6fd5034f@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/15 at 10:02am, Jiri Benc wrote:
> On Fri, 16 Oct 2015 01:06:44 -0700 (PDT), David Miller wrote:
> > No, it's definitely not OK, because lwtunnel support exists in
> > Linus's tree.
> > 
> > And tools should be able to work on all kernels where lwtunnel support
> > is available.
> 
> You can consider the lwtunnels feature as not finished in the current
> Linus's tree. It works, it won't change (thus anything using it in its
> current form will continue to work in all the future kernels), but
> mainstream tools won't make use of it until a kernel version later
> which will get some additional support.
> 
> I don't think it's much of a problem and I don't think it is the first
> time this would happen.
> 
> I'm afraid I don't have any solution that could do better.

Maybe we should be more precise here. The detection mechanism is only
for tools which want to know whether lwt or another feature is supported
without going through the pain of creating an object, checking its
attributes and then deleting the object again if no full support was
detected. The existing flow of configuration through iproute2 will be
supported just like for any other new feature that we have introduced.

Therefore, I consider this a future optimization.

This is very much related to the offload problematic we had or still
have of "only program in HW if you can do the full thing vs best effort"
so this flag will be of use in a wider context.
