From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH]PTP:PTP_CHARDEV:add input parameters check to avoid the
 NULL pointer reference
Date: Mon, 5 Dec 2016 09:32:07 +0100
Message-ID: <20161205083207.GB18980@localhost.localdomain>
References: <PS1PR01MB0844B3E001ABF0DF39D1B11BDC830@PS1PR01MB0844.apcprd01.prod.exchangelabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "cxdx2006@gmail.com" <cxdx2006@gmail.com>
To: Deng Feng <feng.deng@Cortina-Access.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <PS1PR01MB0844B3E001ABF0DF39D1B11BDC830@PS1PR01MB0844.apcprd01.prod.exchangelabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 05, 2016 at 08:02:02AM +0000, Deng Feng wrote:
> When we call one function which contained pointers as input parameters,
> we must check the pointers are NULL or not before we make use of them,
> which avoid the NULL pointer reference .

NAK.

These functions belong to an internal kernel API, and the callers
always provide non-NULL arguments.  This isn't some user space
library.

Thanks,
Richard
