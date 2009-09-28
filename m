From: Nix <nix@esperi.org.uk>
Subject: Re: 2.6.31 regression: e1000e jumbo frames no longer
	work: 'Unsupported MTU setting'
Date: Mon, 28 Sep 2009 21:51:18 +0100
Message-ID: <87ab0elrnd.fsf@spindle.srvr.nix>
References: <871vluc5wi.fsf@spindle.srvr.nix>
	<5f2db9d90909261914l3a927f4cya1dc5e4548688bce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>,
	bruce.w.allan@intel.com, linux-kernel@vger.kernel.org
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <5f2db9d90909261914l3a927f4cya1dc5e4548688bce@mail.gmail.com>
	(Alexander Duyck's message of "Sat, 26 Sep 2009 19:14:55 -0700")
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 27 Sep 2009, Alexander Duyck said:
> It looks like the problem is that the 82574 and 82583 seem to have
> their max_hw_frame_size values swapped.  You might try applying the
> patch below.  I am not sure if it will apply since I hand generated it

Applies fine: works fine. Thank you!

> using the git patch that seems to have introduced the problem, and I
> am sending the patch through an untested account that may mangle the
> patch.

Unmangled.

>        I will see about submitting an official patch for this
> sometime next few days.

I wonder if this belongs in -stable? People with an 82574 who are using
jumbo frames may well find their networks not coming up, if like me
they set a bunch of properties in one /sbin/ip call.

------------------------------------------------------------------------------
Come build with us! The BlackBerry&reg; Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9&#45;12, 2009. Register now&#33;
http://p.sf.net/sfu/devconf
