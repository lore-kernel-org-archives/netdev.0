From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH RFC 0/7] Generic UDP Encapsulation
Date: Sat, 4 Jan 2014 14:33:38 -0800
Message-ID: <20140104143338.246740e3@nehalam.linuxnetplumber.net>
References: <alpine.DEB.2.02.1401021400260.32181@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, hkchu@google.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:44773 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755126AbaADWdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 17:33:44 -0500
Received: by mail-pb0-f53.google.com with SMTP id ma3so16956105pbc.40
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 14:33:43 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1401021400260.32181@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2 Jan 2014 14:12:06 -0800 (PST)
Tom Herbert <therbert@google.com> wrote:

> This patch series implements Generic UDP Encapsulation (GUE).
> Intelligently encapsulating packets in UDP leverages device
> support for UDP flows. The 5-tuple hash can be computed for UDP
> to provide good ECMP, RSS, or link aggregation port selection.
> 
> Generic UDP encapsulation refers to encapsulating packets of
> arbitray IP protocols in UDP packets. Two flavors of GUE
> are implemented in these patches:
> 
> 1) Direct protocol encapsulation
> 2) Encapsualtion in generic UDP encapsulation 

Is this a new wire protocol, or a simplification of existing
tunnel code? It seems to be VXLAN without the VNI header.
