From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH (net.git) 0/3] stmmac: fix PTP support
Date: Wed, 26 Oct 2016 10:58:13 +0200
Message-ID: <20161026085812.GD11974@localhost.localdomain>
References: <1477464964-5960-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, alexandre.torgue@st.com,
        rayagond@vayavyalabs.com, linux-kernel@vger.kernel.org,
        seraphin.bonnaffe@st.com
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:39079 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757384AbcJZI6S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 04:58:18 -0400
Content-Disposition: inline
In-Reply-To: <1477464964-5960-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2016 at 08:56:01AM +0200, Giuseppe Cavallaro wrote:
> This subset of patches aim to fix the PTP support
> for the stmmac and especially for 4.x chip series.
> While setting PTP on an ST box with 4.00a Ethernet
> core, the kernel panics due to a broken settings
> of the descriptors. The patches review the
> register configuration, the algo used for configuring
> the protocol, the way to get the timestamp inside
> the RX/TX descriptors and, in the end, the statistics
> displayed by ethtool.
> 
> Giuseppe Cavallaro (3):
>   stmmac: update the PTP header file
>   stmmac: fix PTP support for GMAC4
>   stmmac: fix PTP type ethtool stats

Acked-by: Richard Cochran <richardcochran@gmail.com>
