From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH] net: mvneta: properly disable HW PHY polling and
 ensure adjust_link() works
Date: Thu, 5 Sep 2013 07:36:14 -0400
Message-ID: <20130905113614.GQ19598@titan.lakedaemon.net>
References: <1378304478-21237-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <20130904163245.GI20552@1wt.eu>
 <CACzLR4uDQK2bkcEJQXLe805EfSA8=eF+YH-FTYovHA0q+8Y9NA@mail.gmail.com>
 <20130905051223.GB26000@1wt.eu> <20130905092808.617da416@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lior Amsalem <alior@marvell.com>,
 Jochen De Smet <jochen.armkernel@leahnim.org>,
 Simon Guinot <simon.guinot@sequanux.org>, Ryan Press <ryan@presslab.us>,
 netdev@vger.kernel.org, vdonnefort@lacie.com,
 "David S. Miller" <davem@davemloft.net>, Ethan Tuttle <ethan@ethantuttle.com>,
 stable@vger.kernel.org, Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
 =?iso-8859-1?Q?Ch=E9ny?= Yves-Gael <yves@cheny.fr>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Peter Sanford <psanford@nearbuy.io>, Willy Tarreau <w@1wt.eu>,
 linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20130905092808.617da416@skate>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 05, 2013 at 09:28:08AM +0200, Thomas Petazzoni wrote:
>  (2) Use the "impedance matcher" code written by Daniel Mack and
>      extended by Jason Cooper, available at
>      https://github.com/zonque/pxa-impedance-matcher. Essentially, it
>      inserts a small binary between the installed bootloader and the
>      kernel, that for example allows to choose a particular DTB amongst
>      several, depending on the board that is detected. I believe it
>      could probably be extended to cover other use cases such as
>      modifying the DTB to add the MAC addresses where appropriate. I've
>      added Jason Cooper in the Cc list if he wants to comment on that.

Yes, I'm hoping to add the dtb editing support sometime over the next
few weeks.  That way, we can use Willy's atags patch in there, and the
kernel never knows the difference.

It isn't high on my priority list atm, so if someone else is motivated,
I've been borrowing code from barebox to flesh out impedance-matcher.
Patches are welcomed ;-)

thx,

Jason.
