From: maximilian attems <janitor@sternwelten.at>
Subject: Re: [Kernel-janitors] [PATCH 2.6.9-rc2 17/38] net/islpci_dev: replace schedule_timeout() with msleep()
Date: Fri, 24 Sep 2004 18:34:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040924163400.GA3118@stro.at>
References: <20040923221303.GB13244@us.ibm.com> <20040923221303.GB13244@us.ibm.com> <5.1.0.14.2.20040924074745.00b1cd40@pop.t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, netdev@oss.sgi.com,
        mcgrof@studorgs.rutgers.edu, kernel-janitors@lists.osdl.org,
        jgarzik@pobox.com, prism54-devel@prism54.org, hvr@gnu.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Margit Schubert-While <margitsw@t-online.de>
Content-Disposition: inline
In-Reply-To: <5.1.0.14.2.20040924074745.00b1cd40@pop.t-online.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 24 Sep 2004, Margit Schubert-While wrote:
..
> The patch has wrong line numbers. Doesn't take into account the stacked up
> netdev changes. (Therefore CC'ing Jeff Garzik)

sure the kj patches are against mainline.
 
> This breaks 2.4 compatibility.
> So either backport to 2.4 or Nish can take over prism54 2.4 maintenance ;-)

can't remember the last time when Randy submitted janitorial patches to
2.4.x, but it's long ago.  2.4 is in maintenance mode.
 
> Don't say a backport is not possible/reasonable, it happened with 
> netdev_priv().
> (In 2.4.27; At least there, we have HAVE_NETDEV_PRIV).

there must have been serious reasons for that.
 
> If this is going to be forced, can we at least have a
> define HAVE_MSLEEP in delay.h ?
> 
> I am somewhat confused by the second part of the patch.
> What has that got to do with msleep ?

basically a lot, because as prism54 lots of drivers forgo/et to set
there state when calling schedule_timeout().

> Actually, the fix would appear to be correct, but that is a seperate issue
> and nothing to do with msleep.
> (Prims54 developers -> I'll take a look over the weekend)

great, please also remove the unused TRACE macro.
(patch was sent to netdev on 3. Sept).
the kj mailing list got another submission to correct 
the __FUNCTION__ use their. :)
 
> I am sceptical about the whole msleep patchset as, by their own admission,
> the janitors have/can not (no hardware) test the majority of the changes.
> Even more worrying is that incorrect code has directly appeared in
> mainline kernel BK.

the named small errors were quickly corrected.
it's up to the driver MAINTAINER to prove us wrong.
we got lots of ack in between.

--
maks
kernel janitor  	http://janitor.kernelnewbies.org/
