From: marcelo.leitner@gmail.com
Subject: Re: [PATCHv4 net-next 3/5] sctp: implement sender-side procedures
 for SSN/TSN Reset Request Parameter
Date: Fri, 20 Jan 2017 18:47:01 -0200
Message-ID: <20170120204701.GW3781@localhost.localdomain>
References: <cover.1484934853.git.lucien.xin@gmail.com>
 <ae54d06e442d8fba6a5983fb81fb4c8ae4bee3ef.1484934853.git.lucien.xin@gmail.com>
 <20170120182521.GV3781@localhost.localdomain>
 <20170120.140034.1018095629148946810.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lucien.xin@gmail.com, netdev@vger.kernel.org,
        linux-sctp@vger.kernel.org, nhorman@tuxdriver.com,
        vyasevich@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40834 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753489AbdATUrX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Jan 2017 15:47:23 -0500
Content-Disposition: inline
In-Reply-To: <20170120.140034.1018095629148946810.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 20, 2017 at 02:00:34PM -0500, David Miller wrote:
> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Date: Fri, 20 Jan 2017 16:25:22 -0200
> 
> > I talked offline with Xin about this and we cannot do it this way.
> > Unfortunatelly we will have to take the long road here, because then
> > we may send data while sending the request, as the streams are not
> > closed yet.  We really need to close team, send the request, and
> > re-open if the send fails.
> 
> I am expecting another spin of this series, correct?

Yes.
