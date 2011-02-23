From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] cls_u32: fix sparse warnings
Date: Wed, 23 Feb 2011 07:35:42 -0500
Message-ID: <1298464542.2271.1.camel@mojatatu>
References: <20110220181423.492594b7@nehalam>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:62865 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754632Ab1BWMfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 07:35:47 -0500
Received: by iwn34 with SMTP id 34so1511109iwn.19
        for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 04:35:46 -0800 (PST)
In-Reply-To: <20110220181423.492594b7@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-02-20 at 18:14 -0800, Stephen Hemminger wrote:
> The variable _data is used in asm-generic to define sections
> which causes sparse warnings, so just rename the variable.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

Hey, while you are sparsing away you may wanna fix 
br_fdb_cleanup() as well ;-> /me runs

cheers,
jamal

