From: Roland Dreier <roland@topspin.com>
Subject: Re: [PATCH][v5][0/24] Latest IB patch queue
Date: Tue, 28 Dec 2004 15:24:43 -0800
Message-ID: <52pt0uhupw.fsf@topspin.com>
References: <200412272150.IBRnA4AvjendsF8x@topspin.com>
	<20041227225417.3ac7a0a6.davem@davemloft.net>
	<52pt0unr0i.fsf@topspin.com>
	<20041228141710.4daebcfb.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041228141710.4daebcfb.davem@davemloft.net> (David S.
	Miller's message of "Tue, 28 Dec 2004 14:17:10 -0800")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

    David> I believe that you didn't test the sparc64 build of the
    David> infiniband stuff because arch/sparc64/Kconfig needs to
    David> explicitly include the infiniband Kconfig since it does not
    David> use drivers/Kconfig.  You didn't send me any such changes.

Actually I did test the build (and Tom Duffy at Sun has actually run
the drivers on his system), but I forgot to include the required Kconfig
change -- I just have it in my local test tree.

    David> There are a few platforms which also are in this situation.
    David> I added the sparc64 one to my tree while integrating your
    David> changes, but the others need to be attended to if you wish
    David> infiniband to be configurable on them.

I think sparc64 is the only such platform where InfiniBand is likely
to be of much interest.  However I'll check out all of arch/ and send
patches to hook up drivers/infiniband/ to the relevant maintainers
once IB makes it upstream.

Thanks,
  Roland
