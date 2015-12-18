From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH iproute2] lwtunnel: fix argument parsing
Date: Thu, 17 Dec 2015 17:16:31 -0800
Message-ID: <20151217171631.4ea010c0@xeon-e3>
References: <f105b591ec43f65607f9d08d46af4612bb75e8cd.1450178247.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Roopa Prabhu <roopa@cumulusnetworks.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:24703 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753234AbbLRBQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 20:16:29 -0500
In-Reply-To: <f105b591ec43f65607f9d08d46af4612bb75e8cd.1450178247.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Dec 2015 12:18:04 +0100
Paolo Abeni <pabeni@redhat.com> wrote:

> Currently parse_encap_ip() does not update correctly argv/argc;
> if multiple lwtunnel arguments are provided, the parsing fails after
> the first one, i.e.
> 
>  ip route add 172.16.101.0/24 dev vxlan1 encap ip id 42 dst 192.168.255.1
> 
> fails with:
> 
>  Error: either "to" is duplicate, or "dst" is a garbage.
> 
> This commit addresses the issue, stepping to next argument at each iteration
> of the parsing loop.
> 
> Fixes: 1e5293056a02 ("lwtunnel: Add encapsulation support to ip route")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied, thanks
