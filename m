From: Ravi Aysola <ravi.mlists@gmail.com>
Subject: Re: network namespace and DNS lookups
Date: Tue, 18 Dec 2012 10:49:15 -0500
Message-ID: <CAFaHj6HT0c59us_7F9Uh7BYh_YXGRt30=yLOrV=hcrG29YO-qA@mail.gmail.com>
References: <CAFaHj6GVgDf2QXUWyaKYnvOqLJRjG+kA32eEk5psPkmc-RPY1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:51536 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932088Ab2LRPtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 10:49:16 -0500
Received: by mail-wg0-f43.google.com with SMTP id e12so382684wge.22
        for <netdev@vger.kernel.org>; Tue, 18 Dec 2012 07:49:15 -0800 (PST)
In-Reply-To: <CAFaHj6GVgDf2QXUWyaKYnvOqLJRjG+kA32eEk5psPkmc-RPY1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think I sent my earlier email a bit prematurely.  I do have
/etc/netns/<namespace-name>/resolv.conf
files under each of my namespaces. Now the question is, how does a
user space process
(say bind)  look at a namespace specific resolv.conf instead of
default one?  Have any of
these standard applications been modified to work with namespace
specific config files?

thanks again
ravi/

On Tue, Dec 18, 2012 at 10:09 AM, Ravi Aysola <ravi.mlists@gmail.com> wrote:
> Has there been any work in any of the recent kernels to limit the DNS lookup
> to a particular network namespace?  Do we have any facility to specify the
> DNS resolvers on network namespace basis (such as /etc/ns/resolv.conf)?
>
> thank you
> ravi/
