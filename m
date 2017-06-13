From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v1] net: rfkill: gpio: Switch to
 devm_acpi_dev_add_driver_gpios()
Date: Tue, 13 Jun 2017 11:08:35 +0200
Message-ID: <1497344915.6068.8.camel@sipsolutions.net>
References: <20170610191034.53635-1-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        linux-wireless@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:52372 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751834AbdFMJIk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Jun 2017 05:08:40 -0400
In-Reply-To: <20170610191034.53635-1-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-06-10 at 22:10 +0300, Andy Shevchenko wrote:
> Switch to use managed variant of acpi_dev_add_driver_gpios() to
> simplify
> error path and fix potentially wrong assingment if ->probe() fails.
> 
Looks fine, applied.

johannes
