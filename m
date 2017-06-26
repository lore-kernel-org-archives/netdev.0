From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 1/3] ethtool: Add link down reason callback
Date: Mon, 26 Jun 2017 15:34:39 +0200
Message-ID: <20170626133439.GB2623@lunn.ch>
References: <1498050286-17141-1-git-send-email-galp@mellanox.com>
 <1498050286-17141-2-git-send-email-galp@mellanox.com>
 <20170621135809.GC27585@lunn.ch>
 <8e7ffead-350e-bd7f-c7ea-fe057969d0d3@mellanox.com>
 <20170624190435.GN4875@lunn.ch>
 <f216ad74-772b-0f6c-1303-ecb0c12afc96@mellanox.com>
 <20170625151953.GA7799@lunn.ch>
 <d5cd081c-9882-fce8-697c-2be062756962@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        David Decotigny <decot@googlers.com>, kernel-team@fb.com
To: Gal Pressman <galp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35120 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752420AbdFZNe5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Jun 2017 09:34:57 -0400
Content-Disposition: inline
In-Reply-To: <d5cd081c-9882-fce8-697c-2be062756962@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The driver has a good intimate information of his device
> implementation, and hence an analysis done by the device vendor is
> favorable.

For a firmware based NIC, maybe. For a discrete NIC, making use of all
the Linux subsystems, this is going to be hard from within the kernel.

> The driver provider can perform the analysis inside the device (firmware) or in the driver according to his preferences.
> We believe that since devices are becoming smarter, more analysis will be done by the device itself, which has more
> information and faster access.
> Smart NICs/SoCs are very popular this days and this API takes into account the different architectures.
> 
> Since this callback is optional, a user space analysis tool can be added in the future providing more generic analysis approach for
> unsupported devices.

I still fear this is going to be an ethtool call with only one user.

  Andrew
