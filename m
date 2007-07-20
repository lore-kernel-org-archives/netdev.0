From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [ofa-general] Re: [PATCH 04/10] net-sysfs.c changes.
Date: Fri, 20 Jul 2007 17:22:03 +0100
Message-ID: <20070720172203.0eaeea86@oldman>
References: <OF3743242C.0BC81AC3-ON6525731E.00397CC1-6525731E.00399244@in.ibm.com>
	<46A09ACF.20805@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jagana@us.ibm.com, herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, kumarkr@linux.ibm.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	hadi@cyberus.ca, mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, johnpol@2ka.mipt.ru, davem@davemloft.net,
	sri@us.ibm.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46A09ACF.20805@trash.net>
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

On Fri, 20 Jul 2007 13:21:51 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Krishna Kumar2 wrote:
> > Patrick McHardy <kaber@trash.net> wrote on 07/20/2007 03:37:20 PM:
> >
> >
> >   
> >> rtnetlink support seems more important than sysfs to me.
> >>     
> >
> > Thanks, I will add that as a patch. The reason to add to sysfs is that
> > it is easier to change for a user (and similar to tx_queue_len).
> >   
> 

But since batching is so similar to TSO, i really should be part of the
flags and controlled by ethtool like other offload flags.
