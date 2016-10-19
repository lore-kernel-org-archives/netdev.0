From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH (net.git)] stmmac: fix and review the ptp registration.
Date: Wed, 19 Oct 2016 10:40:32 +0300
Message-ID: <20161019074032.GD4418@mwanda>
References: <1476860801-28242-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        linux-kernel@vger.kernel.org,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Rayagond Kokatanur <rayagond@vayavyalabs.com>,
        Nicolas Pitre <nico@linaro.org>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:17849 "EHLO
        userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941358AbcJSO5u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 10:57:50 -0400
Content-Disposition: inline
In-Reply-To: <1476860801-28242-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks good.  This actually fixes my commit where I changed the return
PTR_ERR(NULL) which means success to PTR_ERR(-ESOMETHING).
Unintentionally returning success was the correct behavior.

regards,
dan carpenter
