From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2] ss: Fix crash when dump stats from /proc
 with '-p'
Date: Tue, 21 Jul 2015 10:55:21 -0700
Message-ID: <20150721105521.31191a33@urahara>
References: <1437484716-913-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>, j.ps@openmailbox.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36381 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755728AbbGURzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 13:55:12 -0400
Received: by pachj5 with SMTP id hj5so124042736pac.3
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 10:55:12 -0700 (PDT)
In-Reply-To: <1437484716-913-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Jul 2015 16:18:36 +0300
Vadim Kochan <vadim4j@gmail.com> wrote:

> From: Vadim Kochan <vadim4j@gmail.com>
> 
> It really partially reverts:
> 
>     ec4d0d8a9def35 (ss: Replace unixstat struct by new sockstat struct)
> 
> but adds few fields (name & peer_name) from removed unixstat to sockstat struct to easy
> return original code.
> 
> Fixes: ec4d0d8a9def35 (ss: Replace unixstat struct by new sockstat struct)
> Reported-by: Marc Dietrich <marvin24@gmx.de>
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

I applied this one after resolving merge conflicts.
