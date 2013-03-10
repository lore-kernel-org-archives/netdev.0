From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next.git 2/9] stmmac: add IEEE 1588-2002 PTP support
Date: Sun, 10 Mar 2013 13:40:18 +0100
Message-ID: <20130310124018.GD6407@netboy.at.omicron.at>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
 <1362653419-1047-3-git-send-email-peppe.cavallaro@st.com>
 <20130308063437.GB2382@netboy.at.omicron.at>
 <51398CFD.9010605@st.com>
 <20130310122553.GA6407@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bh74.an@samsung.com,
	Rayagond K <rayagond@vayavyalabs.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:48472 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751163Ab3CJMk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 08:40:29 -0400
Received: by mail-ee0-f48.google.com with SMTP id t10so1792425eei.35
        for <netdev@vger.kernel.org>; Sun, 10 Mar 2013 05:40:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130310122553.GA6407@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 10, 2013 at 01:25:54PM +0100, Richard Cochran wrote:
> So what I would like to see is a logical, understandable series of
> small steps, but when new code appears, it is the real, final form.

Here is the order of patches that has made sense for other cards:

1. add hw time stamping support (all possible kinds) via so_timestamping
2. add ptp hardware clock support via ptp_clock_register

Thanks,
Richard
