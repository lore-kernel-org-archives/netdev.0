From: jamal <hadi@cyberus.ca>
Subject: Re: [patch] ifb double-counts packets
Date: Sat, 23 Dec 2006 08:29:52 -0500
Message-ID: <1166880592.3763.3.camel@localhost>
References: <Pine.LNX.4.64.0612230232410.29784@twinlark.arctic.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:43057 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbWLWN3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Dec 2006 08:29:55 -0500
Received: by wx-out-0506.google.com with SMTP id h27so3032081wxd
        for <netdev@vger.kernel.org>; Sat, 23 Dec 2006 05:29:54 -0800 (PST)
To: dean gaudet <dean@arctic.org>
In-Reply-To: <Pine.LNX.4.64.0612230232410.29784@twinlark.arctic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-23-12 at 02:35 -0800, dean gaudet wrote:
> it seems that ifb counts packets twice... both at xmit time and also in 
> the tasklet.  i'm not sure which one of the two to drop, but here's a 
> patch for dropping the counting at xmit time.

Good catch but not quite right. The correct way to do it is to increment
the rx_ counters instead of tx_ right at the top of  ifb_xmit().

Do you wanna resubmit your patch with these chmages and hopefully tested
for your situation?

cheers,
jamal


