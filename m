From: Roland Dreier <roland@topspin.com>
Subject: Re: [PATCH][v5][0/24] Latest IB patch queue
Date: Tue, 28 Dec 2004 17:36:12 -0800
Message-ID: <52hdm5j377.fsf@topspin.com>
References: <200412272150.IBRnA4AvjendsF8x@topspin.com>
	<20041227225417.3ac7a0a6.davem@davemloft.net>
	<52pt0unr0i.fsf@topspin.com>
	<20041228141710.4daebcfb.davem@davemloft.net>
	<52pt0uhupw.fsf@topspin.com>
	<20041229012817.GA18863@synapse.neuralscape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Karen Shaeffer <shaeffer@neuralscape.com>
In-Reply-To: <20041229012817.GA18863@synapse.neuralscape.com> (Karen
	Shaeffer's message of "Tue, 28 Dec 2004 17:28:17 -0800")
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

    Roland> I think sparc64 is the only such platform where InfiniBand
    Roland> is likely to be of much interest.  However I'll check out
    Roland> all of arch/ and send patches to hook up
    Roland> drivers/infiniband/ to the relevant maintainers once IB
    Roland> makes it upstream.

    Karen> I am interested in Infiniband with x86_64 Opterons.

OK, the current code should work well for you -- x86_64 is probably
the most-tested architecture.

"such platform[s]" in my comment above referred to architectures where
arch/xxx/Kconfig does _not_ include drivers/Kconfig;
arch/x86_64/Kconfig does include that file.  So no change is required
to use the current IB patches on x86_64.  I believe the only
architectures that both support PCI and do not include drivers/Kconfig
in their arch Kconfig are arm, sparc, sparc64 and v850.  Perhaps I'm
wrong, but of those four architectures, sparc64 seems to be the only
one where there would be any interest in using IB.

 - Roland
