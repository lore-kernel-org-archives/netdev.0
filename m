From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH][v5][0/24] Latest IB patch queue
Date: Tue, 28 Dec 2004 14:17:10 -0800
Message-ID: <20041228141710.4daebcfb.davem@davemloft.net>
References: <200412272150.IBRnA4AvjendsF8x@topspin.com>
	<20041227225417.3ac7a0a6.davem@davemloft.net>
	<52pt0unr0i.fsf@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <roland@topspin.com>
In-Reply-To: <52pt0unr0i.fsf@topspin.com>
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

On Tue, 28 Dec 2004 11:48:13 -0800
Roland Dreier <roland@topspin.com> wrote:

> Speaking of build failures, one of my test builds is cross-compiling
> for sparc64 with gcc 3.4.2, which adds __attribute__((warn_unused_result))
> to copy_to_user() et al.  The -Werror in the arch/sparc64 means the
> build fails with

Thanks, I'll check that out.

I believe that you didn't test the sparc64 build of the infiniband stuff
because arch/sparc64/Kconfig needs to explicitly include the infiniband
Kconfig since it does not use drivers/Kconfig.  You didn't send me any
such changes.

There are a few platforms which also are in this situation.
I added the sparc64 one to my tree while integrating your changes,
but the others need to be attended to if you wish infiniband to
be configurable on them.
