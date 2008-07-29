From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [PATCH 3/7] dccp tfrc: Suppress unavoidable "below resolution" warning
Date: Wed, 30 Jul 2008 06:56:22 +1200
Message-ID: <5640c7e00807291156m2af40714h5bbaa0e7677a6f44@mail.gmail.com>
References: <1217268843-19667-1-git-send-email-gerrit@erg.abdn.ac.uk>
	 <1217268843-19667-2-git-send-email-gerrit@erg.abdn.ac.uk>
	 <1217268843-19667-3-git-send-email-gerrit@erg.abdn.ac.uk>
	 <1217268843-19667-4-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: "Gerrit Renker" <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.232]:10364 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340AbYG2S4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 14:56:23 -0400
Received: by wr-out-0506.google.com with SMTP id 69so8380wri.5
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2008 11:56:23 -0700 (PDT)
In-Reply-To: <1217268843-19667-4-git-send-email-gerrit@erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 29, 2008 at 6:13 AM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> In the congestion-avoidance phase a decay of p towards 0 is natural once fewer
> losses are encountered. Hence the warning message "p is below resolution" is
> not necessary, and thus turned into a debug message by this patch.
>
> The TFRC_SMALLEST_P is needed since in theory p never actually reaches 0. When
> no further losses are encountered, the loss interval I_0 grows in length,
> causing p to decrease towards 0, causing X_calc = s/(RTT * f(p)) to increase.
>
> With the given minimum-resolution this congestion avoidance phase stops at some
> fixed value, an approximation formula has been added to the documentation.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
