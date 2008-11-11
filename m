From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Tue, 11 Nov 2008 21:50:36 +0300
Message-ID: <20081111185036.GA17717@ioremap.net>
References: <20081106080316.GA32337@ioremap.net> <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FA8@NASANEXMB10.na.qualcomm.com> <20081106194032.GB31673@ioremap.net> <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FBE@NASANEXMB10.na.qualcomm.com> <7e0dd21a0811070836q8deb631qe8093282229b403e@mail.gmail.com> <FCC0EC655BD1AE408C047268D1F5DF4C3BA61024@NASANEXMB10.na.qualcomm.com> <7e0dd21a0811110343v677c511ck69314fa19ace44b7@mail.gmail.com> <FCC0EC655BD1AE408C047268D1F5DF4C3BA611B5@NASANEXMB10.na.qualcomm.com> <7e0dd21a0811110950g1182b86cv3e938df93f53d29d@mail.gmail.com> <FCC0EC655BD1AE408C047268D1F5DF4C3BA611C3@NASANEXMB10.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johann Baudy <johaahn@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Lovich, Vitali" <vlovich@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kandzendo.ru ([195.178.208.66]:57883 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751826AbYKKSuj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 13:50:39 -0500
Content-Disposition: inline
In-Reply-To: <FCC0EC655BD1AE408C047268D1F5DF4C3BA611C3@NASANEXMB10.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Tue, Nov 11, 2008 at 10:14:54AM -0800, Lovich, Vitali (vlovich@qualcomm.com) wrote:
> Right, we're saying the exact same thing I think.  I had wanted just a void * that is specific to PACKET_MMAP, so that no one else pays the price if they don't need to.  You instead want to make it a feature flag - that's fine I think, but we need to make a note of that in the Kconfig file (that enabling PACKET_MMAP increases all skbs by the size of a long).  I'd still rather prefer using the fragments instead though, because it seems like a reasonable solution that has 0 impact on any other code.

I think you should be almost 200% sure that skb is not allowed to grow up :)

-- 
	Evgeniy Polyakov
