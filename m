From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 6/6] phylib: make phy_scan_fixups() static
Date: Sun, 05 Jan 2014 03:07:19 +0300
Message-ID: <52C8A237.9050805@cogentembedded.com>
References: <201401040413.06853.sergei.shtylyov@cogentembedded.com> <201401040423.43977.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:40751 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754545AbaADXHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 18:07:21 -0500
Received: by mail-lb0-f174.google.com with SMTP id y6so8929839lbh.19
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 15:07:19 -0800 (PST)
In-Reply-To: <201401040423.43977.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/04/2014 04:23 AM, Sergei Shtylyov wrote:

> phy_scan_fixups() isn't and shouldn't be called by the drivers directly, so
> unexport it. And since Florian Fainelli's recent patches, the function is only
> called locally, so we can make it static as well.

    I've even forgot to sign off this one, so reposting the whole series now, 
with 2 new patches...

WBR, Sergei
