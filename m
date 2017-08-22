From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: skb_over_panic when sending esp traffic from a vmware guest
Date: Tue, 22 Aug 2017 07:32:49 +0200
Message-ID: <20170822053249.GK31224@secunet.com>
References: <CY1PR17MB0552F3C75C45DBC72799A0F187830@CY1PR17MB0552.namprd17.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nick Huber <nick.huber@multapplied.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:37916 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751279AbdHVFc5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Aug 2017 01:32:57 -0400
Content-Disposition: inline
In-Reply-To: <CY1PR17MB0552F3C75C45DBC72799A0F187830@CY1PR17MB0552.namprd17.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 17, 2017 at 07:19:03PM +0000, Nick Huber wrote:
> I've been experience the following traceback since upgrading from the 4.9 kernel to the 4.11 branch. I've only seen this in a few VMWare guests and I haven't been able to narrow down what exactly is causing it. I'm not familiar with kernel debugging but any help in tracing this down would be appreciated.

Can you give some details about your setup?

>From the backtrace I see that you use GRE tunnels.
How is the setup of the GRE tunnel and the SAs?
How is routing done? In particular I'm interested
if you use routing by netfilter or socket marks.
