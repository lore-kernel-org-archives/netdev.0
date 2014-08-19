From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] drivers: net: ethernet: intel: e1000:
 e1000_ethertoo.c coding style fixes
Date: Tue, 19 Aug 2014 11:01:48 -0700
Message-ID: <1408471308.23250.10.camel@joe-AO725>
References: <1408393263-18027-1-git-send-email-cristos@vipserv.org>
	 <CAL3LdT7+5FFbP5Rf1MoY2GJ9cQ0LJnecQb66ZA2ofwD28vy1jw@mail.gmail.com>
	 <53F38A84.3070702@vipserv.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53F38A84.3070702@vipserv.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-08-19 at 19:33 +0200, Krzysztof Majzerowicz-Jaszcz wrote:
> On 19/08/14 18:04, Jeff Kirsher wrote:
> > On Mon, Aug 18, 2014 at 3:21 PM, Krzysztof Majzerowicz-Jaszcz
> > <cristos@vipserv.org> wrote:
> >> Fixed many errors/warnings and checks in e1000_ethtool.c reported by checkpatch.pl
> >> Suggestions from Joe Perches and Alexander Duyck applied as well
> >>
> >> Signed-off-by: Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org>
> >> ---
> >>  drivers/net/ethernet/intel/e1000/e1000_ethtool.c | 155 ++++++++++++-----------
> >>  1 file changed, 79 insertions(+), 76 deletions(-)
> >>
> > 
> > Thanks Krzysztof, I will add your patch to my queue and I can fix up
> > the patch title for you. :-)
> >
> 
> Thank you :). Sorry for that patch title - I guess that 'first pancake is always spoiled'.
> Nonetheless, that makes my first successful contribution to the kernel <yay> ;)

Yay for Krzysztof.

Now you could fix the same "*(foo + bar) == 0xXX" uses
in drivers/net/ethernet/intel/e1000e/ethtool.c

drivers/net/ethernet/intel/e1000e/ethtool.c:	if (*(skb->data + 3) == 0xFF)
drivers/net/ethernet/intel/e1000e/ethtool.c:		if ((*(skb->data + frame_size / 2 + 10) == 0xBE) &&
drivers/net/ethernet/intel/e1000e/ethtool.c:		    (*(skb->data + frame_size / 2 + 12) == 0xAF))

as well if you wanted to follow up on your first success.
