From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 04/10] net-sysfs.c changes.
Date: Sat, 21 Jul 2007 12:16:30 +0530
Message-ID: <OFFAA4E4C4.F1496A54-ON6525731F.0025194E-6525731F.0025379C@in.ibm.com>
References: <20070720172203.0eaeea86@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	Patrick McHardy <kaber@trash.net>, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, sri@us.ibm.com, davem@davemloft.net,
	rdreier@cisco.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070720172203.0eaeea86@oldman>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> wrote on 07/20/2007
09:52:03 PM:
> Patrick McHardy <kaber@trash.net> wrote:
>
> > Krishna Kumar2 wrote:
> > > Patrick McHardy <kaber@trash.net> wrote on 07/20/2007 03:37:20 PM:
> > >
> > >
> > >
> > >> rtnetlink support seems more important than sysfs to me.
> > >>
> > >
> > > Thanks, I will add that as a patch. The reason to add to sysfs is
that
> > > it is easier to change for a user (and similar to tx_queue_len).
> > >
> >
>
> But since batching is so similar to TSO, i really should be part of the
> flags and controlled by ethtool like other offload flags.

So should I add all three interfaces (or which ones) :

      1. /sys (like for tx_queue_len)
      2. netlink
      3. ethtool.

Or only 2 & 3 are enough ?

thanks,

- KK
