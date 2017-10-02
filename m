From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] ibmvnic: Improve output for unsupported stats
Date: Mon, 2 Oct 2017 23:57:23 +0200
Message-ID: <20171002215723.GN17713@lunn.ch>
References: <6ce14d1a-11cc-37be-e6ca-b9ec4afb01a8@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
To: John Allen <jallen@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:36258 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751888AbdJBV5Z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 17:57:25 -0400
Content-Disposition: inline
In-Reply-To: <6ce14d1a-11cc-37be-e6ca-b9ec4afb01a8@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 02, 2017 at 03:31:39PM -0500, John Allen wrote:
> The vnic server can report -1 in the event that a given statistic is not
> supported. Currently, the -1 value is implicitly cast to an unsigned
> integer and appears through the ethtool -S output as a very large number.
> This patch improves this behavior by reporting 0 in the event that a
> given statistic is not supported.

Hi John

If it does not exist, why not skip it altogether?
ibmvnic_get_sset_count() could walk the list and count the valid ones.
ibmvnic_get_strings() could only return the name of the valid onces.

      Andrew
