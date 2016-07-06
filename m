From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: Network hang after c3f1010b30f7fc611139cfb702a8685741aa6827 with
 CIPSO & Smack
Date: Tue, 5 Jul 2016 17:49:41 -0700
Message-ID: <7d833f59-c68f-f779-4de4-15bc0b26ac7c@cumulusnetworks.com>
References: <e5ba1ba9-acf6-c36c-03e4-4cdc81e81648@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux-Netdev <netdev@vger.kernel.org>
To: Casey Schaufler <casey@schaufler-ca.com>,
	David Miller <davem@davemloft.net>,
	Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35968 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbcGFAto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 20:49:44 -0400
Received: by mail-pf0-f171.google.com with SMTP id t190so74793457pfb.3
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 17:49:43 -0700 (PDT)
In-Reply-To: <e5ba1ba9-acf6-c36c-03e4-4cdc81e81648@schaufler-ca.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/5/16 5:38 PM, Casey Schaufler wrote:
> I have encountered a system hang with my Smack
> networking tests that bisects to the change below.
> I can't say that I have any idea why the change
> would impact the Smack processing, but there appears
> to be some serious packet processing going on. The
> Smack code is using CIPSO on the loopback interface.
> The test is supposed to verify that labels can be
> set on the packets using CIPSO. Unlabeled packets
> do not appear to be impacted. I do not know if SELinux
> is affected, and if not, why not. Smack and SELinux
> use CIPSO differently.

What are the commands to repeat the test?
