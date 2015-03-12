From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Question]: Details on TCP_INFO extension
Date: Thu, 12 Mar 2015 11:36:05 -0700
Message-ID: <1426185365.11398.171.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54E661BF.4020404@psc.edu>
	 <20150312175837.GE1032293@devbig242.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: tcpinst-wg@psc.edu, rapier <rapier@psc.edu>,
	Yuchung Cheng <ycheng@google.com>,
	netdev <netdev@vger.kernel.org>, kernel-team@fb.com
To: Martin Lau <kafai@fb.com>, Eric Salo <salo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:32923 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812AbbCLSgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 14:36:19 -0400
Received: by iecvj10 with SMTP id vj10so51832425iec.0
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 11:36:18 -0700 (PDT)
In-Reply-To: <20150312175837.GE1032293@devbig242.prn2.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-12 at 10:58 -0700, Martin Lau wrote:
> Old Title: [Tcpinst-wg] Welcome to the TCP Instrumentation List
> 
> On Thu, Feb 19, 2015 at 05:20:47PM -0500, rapier wrote:
> > There should be two sets of instruments. Operational and diagnostic. The 
> > operation instruments will be be used to extend TCP_INFO and will always 
> > be available. Google will be providing a patch for upstream with 8 
> > instruments in this category. The diagnostic instruments will be enabled 
> > by the user on an as needed basis. These data from these instruments 
> > will be stored in a separate structure that is referenced by a pointer 
> > in the socket or some other mechanism. The ability to only enable a 
> > subset of these instruments should be a design goal.
> Can Google share which 8 fields will be added to TCP_INFO?
> 
> Thanks,
> --Martin
> --

CC Eric Salo, who is working on this topic.

Note that I upstreamed yesterday support for an unified socket cookie.

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=33cf7c90fe2f97afb1cadaa0cfb782cb9d1b9ee2
