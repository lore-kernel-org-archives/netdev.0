From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [ISSUE: sky2 - rx error] Link stops working under heavy traffic
 load connected to a mv88e6176
Date: Tue, 16 May 2017 17:58:43 +0200
Message-ID: <20170516155843.GE32357@lunn.ch>
References: <20170427130450.GL17172@lunn.ch>
 <59032D8B.1010801@aoifes.com>
 <20170428122259.GH13231@lunn.ch>
 <59105EA3.9030203@aoifes.com>
 <20170508123852.GI27709@lunn.ch>
 <591AD990.901@aoifes.com>
 <20170516124759.GB27959@lunn.ch>
 <591AF9FD.1000304@aoifes.com>
 <20170516132116.GE5456@lunn.ch>
 <591B1FC2.1090402@aoifes.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: Rafa Corvillo <rafael.corvillo@aoifes.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60540 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750876AbdEPP6s (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 11:58:48 -0400
Content-Disposition: inline
In-Reply-To: <591B1FC2.1090402@aoifes.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >Also, check that in sky2_rx_add(), le->length is set to 4K.
> >
> 
> The value of le->length is set to 1520.

> Rafa

Ah.

You probably need to change sky2_get_rx_data_size() as well, to add in
the extra 8 bytes.

    Andrew
