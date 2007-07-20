From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 03/10] dev.c changes.
Date: Fri, 20 Jul 2007 17:39:18 +0530
Message-ID: <OFA7D22363.1BE2EB19-ON6525731E.0042AA56-6525731E.0042C514@in.ibm.com>
References: <46A09A85.7020500@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, davem@davemloft.net, sri@us.ibm.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46A09A85.7020500@trash.net>
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

Patrick McHardy <kaber@trash.net> wrote on 07/20/2007:

> I can't really argue about the numbers, but it seems to me that only
> devices which *usually* have a sufficient queue length will support
> this, and anyone setting the queue length of a gbit device to <16 is
> begging for trouble anyway. So it doesn't really seem worth to bloat
> the code for handling an insane configuration as long as it doesn't
> break.

Ah, I get your point now. So if driver sets BATCHING and user then sets
queue_len to (say) 4, then poor results are expected (and kernel doesn't
need to try fix it). Same for driver setting BATCHING when it's queue is
small in the first place, which no driver writer should do anyway. I think
it makes the code a lot easier too. Will update.

thanks,

- KK
