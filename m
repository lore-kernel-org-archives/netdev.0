From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 10/13] staging: r8188eu: Remove wrapper _enter_critical_mutex()
Date: Sun, 16 Feb 2014 23:35:46 -0600
Message-ID: <53019FB2.6070804@lwfinger.net>
References: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net> <1392418457-3203-11-git-send-email-Larry.Finger@lwfinger.net> <20140215203811.GA17742@kroah.com> <20140215204112.GA14963@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:44426 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbaBQFft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 00:35:49 -0500
Received: by mail-ob0-f169.google.com with SMTP id wo20so16621877obc.28
        for <netdev@vger.kernel.org>; Sun, 16 Feb 2014 21:35:48 -0800 (PST)
In-Reply-To: <20140215204112.GA14963@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/15/2014 02:41 PM, Greg KH wrote:
> On Sat, Feb 15, 2014 at 12:38:11PM -0800, Greg KH wrote:
>> I've applied this series up to here.
>
> Nevermind, the others applied, so I've merged them, just not this patch.

I have split this patch into two parts that I will send tomorrow. The first one 
just replaces the wrapper. The second uses the returned value to report any 
errors that occur, a step that original code skipped.

Larry
