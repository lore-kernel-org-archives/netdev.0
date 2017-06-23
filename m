From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH -net] tls: return -EFAULT if copy_to_user() fails
Date: Fri, 23 Jun 2017 03:31:44 -0700
Message-ID: <1498213904.24295.10.camel@perches.com>
References: <20170623101544.c5bvwe5cd6e46bd5@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Aviad Yehezkel <aviadye@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>,
        Dave Watson <davejwatson@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0130.hostedemail.com ([216.40.44.130]:59625 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754510AbdFWKbs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 06:31:48 -0400
In-Reply-To: <20170623101544.c5bvwe5cd6e46bd5@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-06-23 at 13:15 +0300, Dan Carpenter wrote:
> The copy_to_user() function returns the number of bytes remaining but we
> want to return -EFAULT here.

because?
