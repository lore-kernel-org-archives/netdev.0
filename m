From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip tap: Simplify add 'tap' device w/o mode
Date: Sun, 1 Mar 2015 14:07:15 -0800
Message-ID: <20150301140715.0a2c7ef2@urahara>
References: <1425117586-21461-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:41072 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751937AbbCAWHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 17:07:14 -0500
Received: by iecrd18 with SMTP id rd18so43307298iec.8
        for <netdev@vger.kernel.org>; Sun, 01 Mar 2015 14:07:14 -0800 (PST)
In-Reply-To: <1425117586-21461-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 28 Feb 2015 11:59:46 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> From: Vadim Kochan <vadim4j@gmail.com>
> 
> It allows add 'tap' device w/o specify mode:
> 
>     # ip tap add tap0
> 
> instead of return error message.
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

No. mode should not depend on device name.

Also, I noticed that reading kernel code it is possible to
create a broken tun device if type is not set.
