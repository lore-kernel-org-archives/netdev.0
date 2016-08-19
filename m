From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net v2] sctp: linearize early if it's not GSO
Date: Fri, 19 Aug 2016 06:28:37 -0300
Message-ID: <20160819092837.GH3110@localhost.localdomain>
References: <c333cd2ab2c828577251c6f75a3cc5e5f3683eb8.1471542789.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52730 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753671AbcHSJ2m (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 05:28:42 -0400
Content-Disposition: inline
In-Reply-To: <c333cd2ab2c828577251c6f75a3cc5e5f3683eb8.1471542789.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 18, 2016 at 05:46:37PM -0300, Marcelo Ricardo Leitner wrote:
> Because otherwise when crc computation is still needed it's way more
> expensive than on a linear buffer to the point that it affects
> performance.

Please ignore the 2nd copy (same MessageId). I thought it got lost
somehow and sent it again.
