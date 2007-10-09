From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 9 Oct 2007 08:39:31 +0530
Message-ID: <OFDE12F216.8E927E22-ON6525736F.001137D0-6525736F.00115A01@in.ibm.com>
References: <1191849444.4352.29.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, gaagaan@gmail.com, jeff@garzik.org,
	Robert.Olsson@data.slu.se, kumarkr@linux.ibm.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com, shemminger@linux-foundation.org,
	David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1191849444.4352.29.camel@localhost>
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

J Hadi Salim <j.hadi123@gmail.com> wrote on 10/08/2007 06:47:24 PM:

> two, there should _never_ be any requeueing even if LLTX in the previous
> patches when i supported them; if there is, it is a bug. This is because
> we dont send more than what the driver asked for via xmit_win. So if it
> asked for more than it can handle, that is a bug. If its available space
> changes while we are sending to it, that too is a bug.

Driver might ask for 10 and we send 10, but LLTX driver might fail to get
lock and return TX_LOCKED. I haven't seen your code in greater detail, but
don't you requeue in that case too?

- KK
