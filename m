From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: nf_nat_tftp broken in 4.8?
Date: Wed, 9 Nov 2016 14:18:50 -0800
Message-ID: <84639b86-1e69-86c0-5395-c77b3630ec73@gmail.com>
References: <b3fb3d07-fb0b-e4a5-20fe-bdc2abc8f6fc@gmail.com>
 <20161109215614.GA21923@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        fgao@ikuai8.com, pablo@netfilter.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33978 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754268AbcKIWSx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 17:18:53 -0500
In-Reply-To: <20161109215614.GA21923@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/2016 01:56 PM, Florian Westphal wrote:
> Florian Fainelli <f.fainelli@gmail.com> wrote:
>> After updating my workstation from 4.4 to 4.8, which also serves as a
>> NAT gateway for local machines, I noticed that TFTP across this NAT box
>> broke:
> 
> does 'sysctl net.netfilter.nf_conntrack_helper=1' help?
> 

It does yes, thanks, and apologies for not seeing that earlier.
-- 
Florian
