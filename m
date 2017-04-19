From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] dp83640: don't recieve time stamps twice
Date: Wed, 19 Apr 2017 13:54:28 +0200
Message-ID: <20170419115428.GB3444@localhost.localdomain>
References: <20170418191426.GA17838@mwanda>
 <1492593414.3108.1.camel@spectralink.com>
 <20170419103135.GA1670@localhost.localdomain>
 <1492601312.3108.3.camel@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dan.carpenter@oracle.com" <dan.carpenter@oracle.com>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: =?iso-8859-1?B?U/hyZW5zZW4s?= Stefan
        <Stefan.Sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:35190 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762581AbdDSLyh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 07:54:37 -0400
Content-Disposition: inline
In-Reply-To: <1492601312.3108.3.camel@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 19, 2017 at 11:28:34AM +0000, Sørensen, Stefan wrote:
> Here we still hold rx_lock while during the callback, wouldn't it be
> beneficial to release that first?

Yes, your are right.

Do you want to post a fix?  If not, I will, but later on this week.

Thanks,
Richard
