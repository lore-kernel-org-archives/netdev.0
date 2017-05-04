From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC] iproute: Add support for extended ack to rtnl_talk
Date: Thu, 4 May 2017 09:42:12 -0700
Message-ID: <20170504094212.5a9f0d42@xeon-e3>
References: <20170503235638.31116-1-stephen@networkplumber.org>
        <590AF624.6090808@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33894 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753246AbdEDQmU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 12:42:20 -0400
Received: by mail-pg0-f42.google.com with SMTP id v1so11348807pgv.1
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 09:42:20 -0700 (PDT)
In-Reply-To: <590AF624.6090808@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 04 May 2017 11:36:36 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 05/04/2017 01:56 AM, Stephen Hemminger wrote:
> > Add support for extended ack error reporting via libmnl. This
> > is a better alternative to use existing library and not copy/paste
> > code from the kernel. Also make arguments const where possible.
> >
> > Add a new function rtnl_talk_extack that takes a callback as an input
> > arg. If a netlink response contains extack attributes, the callback is
> > is invoked with the the err string, offset in the message and a pointer
> > to the message returned by the kernel.
> >
> > Adding a new function allows commands to be moved over to the
> > extended error reporting over time.
> >
> > For feedback, compile tested only.  
> 
> Just out of curiosity, what is the plan regarding converting iproute2
> over to libmnl (ip, tc, ss, ...)? In 2015, tipc tool was the first
> user merged that requires libmnl, the only other user today in the
> tree is devlink, which even seems to define its own libmnl library
> helpers. What is the clear benefit/rationale of outsourcing this to
> libmnl? I always was the impression we should strive for as little
> dependencies as possible?
> 
> I don't really like that we make extended ack reporting now dependent
> on libmnl, which further diverts from iproute's native nl library vs
> requiring to install another nl library, making the current status
> quo even worse ... :/
> 
> Thanks,
> Daniel

No rush for migration. just slow migration as time permits.
This would be good kernel janitor type project.
