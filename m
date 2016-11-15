From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 iproute2 1/1] tc: print raw qdisc handle.
Date: Tue, 15 Nov 2016 10:30:04 -0800
Message-ID: <20161115103004.7d2043e9@samsung9>
References: <1479164360-24188-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:34958 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752922AbcKOSgD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 13:36:03 -0500
Received: by mail-pg0-f52.google.com with SMTP id p66so69320943pga.2
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 10:36:02 -0800 (PST)
In-Reply-To: <1479164360-24188-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Nov 2016 17:59:20 -0500
Roman Mashak <mrv@mojatatu.com> wrote:

> This is v2 patch with fixed code indentation.
> 
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied, but inverted the if() since it reads better if code
is:
   if (show_raw)
	...
   else
	...
