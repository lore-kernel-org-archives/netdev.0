From: jamal <hadi@cyberus.ca>
Subject: Re: kernel mode pppoe ppp if + ifb + mirred redirect, ethernet
	packets in ifb?!
Date: Mon, 12 Oct 2009 16:57:44 -0400
Message-ID: <1255381064.5406.30.camel@dogo.mojatatu.com>
References: <200910121143.39924.denys@visp.net.lb>
	 <1255353047.5406.12.camel@dogo.mojatatu.com>
	 <200910121715.35676.denys@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f186.google.com ([209.85.221.186]:62649 "EHLO
	mail-qy0-f186.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756715AbZJLVBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 17:01:22 -0400
Received: by qyk16 with SMTP id 16so2672168qyk.15
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2009 14:00:45 -0700 (PDT)
In-Reply-To: <200910121715.35676.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-10-12 at 17:15 +0300, Denys Fedoryschenko wrote:
> How it can be ethernet packets (with PPPoE headers) if i am redirecting from 
> ppp interface, not ethernet interface?
> 

You are running this on ingress. If you run on egress you will see
proper header.
_Most people_ want to see the whole original header for qos accounting
purposes etc. PPPOE claims to be ethernet, PPP does not. Hence
difference in observation. 

We could add an override feature to say "i only want 
see what was passed not wire packet". 
If this is important to you let me know and i will try to make time to
add it (with hopefully not breaking old scripts); if you feel brave as
well i could guide you on how to add it.

cheers,
jamal

