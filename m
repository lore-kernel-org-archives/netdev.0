From: maximilian attems <janitor@sternwelten.at>
Subject: Re: [Kernel-janitors] Re: [patch 1/8] irda/act200l-sir: replace
	schedule_timeout() with msleep()
Date: Thu, 2 Sep 2004 00:58:42 +0200
Sender: kernel-janitors-bounces@lists.osdl.org
Message-ID: <20040901225841.GF7467@stro.at>
References: <E1C2cIF-0007yy-Lb@sputnik>
	<20040901210929.GA11442@bougret.hpl.hp.com>
	<20040901214003.GC7467@stro.at>
	<20040901214815.GA13071@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============9078948611254507=="
Cc: kj <kernel-janitors@osdl.org>, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <kernel-janitors-bounces@lists.osdl.org>
To: jt@hpl.hp.com
In-Reply-To: <20040901214815.GA13071@bougret.hpl.hp.com>
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============9078948611254507==
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, 01 Sep 2004, Jean Tourrilhes wrote:

> On Wed, Sep 01, 2004 at 11:40:03PM +0200, maximilian attems wrote:
> > On Wed, 01 Sep 2004, Jean Tourrilhes wrote:
..
> > 
> > hmm we have still archs were HZ < 100.
> > i find msleep use msecs units a lot more readable than
> > 	schedule_timeout((HZ + 99) / 100);
> > 
> > the schedule_timeout(HZ/100) gets safely converted with msleep.
> 
> 	I don't have complain about converting the (HZ + 99) / 100
> expressions to something saner. My beef is the fact that msleep hide
> the fact that a schedule might happen. This is important in the IrDA
> code.

sorry my woding was confusing:
(HZ + 99) / 100 is correct!
as msleep(10)
 
--
maks
kernel janitor  	http://janitor.kernelnewbies.org/



--===============9078948611254507==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============9078948611254507==--
