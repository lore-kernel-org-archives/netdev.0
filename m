From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Driver profiles RFC
Date: Tue, 8 Aug 2017 15:54:36 +0200
Message-ID: <20170808135436.GA2015@lunn.ch>
References: <6d8560fa-8346-0c43-272d-d39be65ea82f@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        ivecera@redhat.com, roopa@cumulusnetworks.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        john.fastabend@gmail.com, Jiri Pirko <jiri@resnulli.us>,
        mlxsw <mlxsw@mellanox.com>
To: Arkadi Sharshevsky <arkadis@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:56335 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752059AbdHHNym (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Aug 2017 09:54:42 -0400
Content-Disposition: inline
In-Reply-To: <6d8560fa-8346-0c43-272d-d39be65ea82f@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 08, 2017 at 04:15:41PM +0300, Arkadi Sharshevsky wrote:
> Drivers may require driver specific information during the init stage.
> For example, memory based shared resource which should be segmented for
> different ASIC processes, such as FDB and LPM lookups.

Hi Arkadi

Have you looked around other subsystems to see if they have already
solved this problem?

How about GPUs? Do they have a similar requirement?

This seems like a generic problem for 'smart' peripherals. How would
you use dpipe with a GPU for example?

    Andrew
