From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next.git 2/9] stmmac: add IEEE 1588-2002 PTP support
Date: Sun, 10 Mar 2013 13:25:54 +0100
Message-ID: <20130310122553.GA6407@netboy.at.omicron.at>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
 <1362653419-1047-3-git-send-email-peppe.cavallaro@st.com>
 <20130308063437.GB2382@netboy.at.omicron.at>
 <51398CFD.9010605@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bh74.an@samsung.com,
	Rayagond K <rayagond@vayavyalabs.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:54848 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762Ab3CJM0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 08:26:10 -0400
Received: by mail-ee0-f49.google.com with SMTP id d41so1727140eek.22
        for <netdev@vger.kernel.org>; Sun, 10 Mar 2013 05:26:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <51398CFD.9010605@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 08, 2013 at 08:02:21AM +0100, Giuseppe CAVALLARO wrote:
> On 3/8/2013 7:34 AM, Richard Cochran wrote:

> >>+
> >>+static int enh_desc_get_rx_timestamp_status(struct dma_desc *p)
> >>+{
> >>+	/* FIXME if Enhance descriptor with 8 DWORDS is enabled */
> >
> >Why not fix these FIXMEs for the next respin?
> 
> This is fixed in the patch #5 where we use the extended descriptors
> for PTP2.

If possible, it is nice for the reviewers and for the logic of the
patch series to order the changes so that these FIXMEs go away.
 
> >>+	struct hwtstamp_config config;
> >>+	struct timespec now;
> >>+	u64 temp = 0;
> >
> >You add this new code here, but you change it all around again a few
> >patches later. Please just submit the final, combined version.
> 
> we kept these separately because the patch #5 (for example) depends on
> another one that adds the extended descriptor support. Also If I add
> all the code in a single patch this will be very big. I had some
> problems to review all separately. So I suspect that if we merge all
> in a single patch this will not help (especially myself). At any rate,
> tell me if you prefer to have a single patch. I can do that.

I am not asking for bigger patches. It is good to arrange your patches
in small steps, since that makes both reviewing and bisecting easier.

However, for brand new code, I find it quite annoying to read one
patch, and then to have it all re-written in the next one. (If a new
function *only* grows during a patch series, that is easy to follow.)

So what I would like to see is a logical, understandable series of
small steps, but when new code appears, it is the real, final form.

Thanks,
Richard
