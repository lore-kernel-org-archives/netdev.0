From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3 01/10] ss: rooted out ss type declarations for output
 formatters
Date: Sun, 23 Aug 2015 10:07:58 -0700
Message-ID: <20150823100758.74a626d4@urahara>
References: <1440103221-21854-1-git-send-email-matthias.tafelmeier@gmx.net>
	<1440103221-21854-2-git-send-email-matthias.tafelmeier@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hagen@jauu.net, shemminger@osdl.org,
	fw@strlen.de, edumazet@google.com, daniel@iogearbox.net
To: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36516 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294AbbHWRHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 13:07:46 -0400
Received: by pawq9 with SMTP id q9so87342508paw.3
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 10:07:45 -0700 (PDT)
In-Reply-To: <1440103221-21854-2-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Aug 2015 22:40:12 +0200
Matthias Tafelmeier <matthias.tafelmeier@gmx.net> wrote:

> The prospected output formatters and ss do share type declarations like
> slabstat or tcpstat so that the decision has been made to centralize
> those declarations in ss_types.h.  Potential future declarations shall
> be placed there. The latter should help amend the extent of ss.c as
> well.
> 
> Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
> Suggested-by: Hagen Paul Pfeifer <hagen@jauu.net>

I looked at this series, and was going to merge it but the code to do
json formatting gets really ugly. Please redo it with the json_writer
code I just added.
