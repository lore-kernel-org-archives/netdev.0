From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [RFC PATCH net-next 3/3] net/mlx5e: Expose link down reason to
 ethtool
Date: Wed, 21 Jun 2017 21:33:53 -0700
Message-ID: <20170621213353.318e5d37@cakuba.netronome.com>
References: <1498050286-17141-1-git-send-email-galp@mellanox.com>
        <1498050286-17141-4-git-send-email-galp@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        David Decotigny <decot@googlers.com>, kernel-team@fb.com
To: Gal Pressman <galp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:33944 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750852AbdFVEeB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 00:34:01 -0400
In-Reply-To: <1498050286-17141-4-git-send-email-galp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Jun 2017 16:04:46 +0300, Gal Pressman wrote:
> Use the new ethtool link down reason api, and expose troubleshooting
> info regarding the link status.
> 
> Signed-off-by: Gal Pressman <galp@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>

Is my reading correct that in case the reason is not in the
pddr2ethtool_table opaque binary data will be passed from the firmware
to user space?  Is there any particular reason to allow for this?  If
it's just for the rare scenario where a new error code needs to be
added perhaps it would be enough to dump the FW-provided message to the
logs?
