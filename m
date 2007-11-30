From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH net-2.6.25] Add packet filtering based on process'ssecurity context.
Date: Fri, 30 Nov 2007 23:59:13 +0900
Message-ID: <200711302359.GGF60963.LtFFFHQVJOSOOM@I-love.SAKURA.ne.jp>
References: <Xine.LNX.4.64.0711231005270.4252@us.intercode.com.au>
	<200711241114.FCJ30702.JSMOFQtVHFFOOL@I-love.SAKURA.ne.jp>
	<m2sl2p8x8e.fsf@synack.fr>
	<200711302307.EJD21822.JFFMQFSOOHLtVO@I-love.SAKURA.ne.jp>
	<m2k5nz3iyo.fsf@synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jmorris@namei.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-security-module@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org, sds@tycho.nsa.gov
To: sam@synack.fr
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <m2k5nz3iyo.fsf@synack.fr>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Samir Bellabes wrote:
> at security_socket_accept(), the user only accept the fact that the
> application is able to go to sock->ops->accept(). That's the purpose of
> this hook.
Yes. This hook can't perform filtering.

> After, when packet are coming, we can catch them with
> libnetfilter_queue, and deal with filtering packets.
Is this performed inside sock->ops->accept()?

> here we agree. *but* in my module, the user don't judge before
> sock->ops->accept(). He judges when packets are coming, throught the
> libnetfilter_queue API, in userspace, and reinject packet if it's ok.
I didn't understand what is happening.
Is there a hook which can perform filtering inside sock->ops->accept()?

Regards.

