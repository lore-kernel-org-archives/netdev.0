From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v2] iproute2: bridge: support vlan range
Date: Thu, 22 Jan 2015 22:51:06 -0800
Message-ID: <20150122225106.569d4b92@urahara>
References: <1421994310-48811-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, vyasevic@redhat.com,
	wkok@cumulusnetworks.com, sfeldma@gmail.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:39893 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbbAWGvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 01:51:17 -0500
Received: by mail-pd0-f182.google.com with SMTP id z10so4413136pdj.13
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 22:51:17 -0800 (PST)
In-Reply-To: <1421994310-48811-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Jan 2015 22:25:10 -0800
roopa@cumulusnetworks.com wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch adds vlan range support to bridge command
> using the newly added vinfo flags BRIDGE_VLAN_INFO_RANGE_BEGIN and
> BRIDGE_VLAN_INFO_RANGE_END.
> 
> $bridge vlan show
> port    vlan ids
> br0      1 PVID Egress Untagged
> 
> dummy0   1 PVID Egress Untagged
> 
> $bridge vlan add vid 10-15 dev dummy0
> port    vlan ids
> br0      1 PVID Egress Untagged
> 
> dummy0   1 PVID Egress Untagged
>          10
>          11
>          12
>          13
>          14
>          15

Doing on vlan id per line gets ridiculous with 1000 vlan's
how about something more compact?
