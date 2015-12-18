From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2 3/3] lwtunnel: implement support for ip6
 encap
Date: Thu, 17 Dec 2015 17:30:40 -0800
Message-ID: <20151217173040.318924d1@xeon-e3>
References: <cover.1450267709.git.pabeni@redhat.com>
	<25335db6a83c31df4a13bfff8dfc4c359f8f1ef9.1450267709.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jiri Benc <jbenc@redhat.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34543 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932384AbbLRBae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 20:30:34 -0500
Received: by mail-pf0-f171.google.com with SMTP id 68so39865711pfc.1
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 17:30:33 -0800 (PST)
In-Reply-To: <25335db6a83c31df4a13bfff8dfc4c359f8f1ef9.1450267709.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Dec 2015 13:22:28 +0100
Paolo Abeni <pabeni@redhat.com> wrote:

> Currently ip6 encap support for lwtunnel is missing.
> This patch implement it, mostly duplicating the ipv4 parts.
> 
> Also be sure to insert a space after the encap type, when
> showing lwtunnel, to avoid the tunnel type and the following
> argument being merged into a single word.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Patch does not apply cleanly. Probably because of recent changes to lwtunnel
and tunnel related arguement parsing.
