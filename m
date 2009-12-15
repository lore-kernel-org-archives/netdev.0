From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH 1/4] net: port mirroring: add tracepoints to
 appropriate network paths
Date: Tue, 15 Dec 2009 08:44:24 -0800
Message-ID: <20091215084424.291459cb@s6510>
References: <20091215162956.GB18710@hmsreliant.think-freely.org>
	<20091215163604.GC18710@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54224 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754548AbZLOQow (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2009 11:44:52 -0500
In-Reply-To: <20091215163604.GC18710@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Dec 2009 11:36:04 -0500
Neil Horman <nhorman@tuxdriver.com> wrote:

> Add net_dev_xmit & net_dev_receive tracepoints
> 
> Add tracepoints at the end of the network stack xmit path and the start of the
> stack receive path.  Among other uses, these tracepoints can be used to tap the
> raw input and output streams for any given network device for the purposes of
> mirroring that traffic to other ports.
> 

There already is a mirroring solution but people don't know how to use it.
Using mirred on ingress qdisc does that.

Why would we want to add another hook to the already complex networking
code path?

https://svn.openfabrics.org/svn/openib/gen2/branches/1.1/src/userspace/ipoibtools/iproute2/doc/actions/mirred-usage
