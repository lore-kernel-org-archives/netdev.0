From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Wed, 02 Dec 2015 19:23:25 +0100
Message-ID: <1449080605.3845593.456079161.39E78A8D@webmail.messagingengine.com>
References: <564B3D35.50004@profihost.ag> <alpine.DEB.2.11.1511171936030.3761@nanos>
 <564B7F9D.5060701@profihost.ag>
 <alpine.DEB.2.11.1511172041480.3761@nanos>
 <564CDE2F.8000201@profihost.ag> <564CEB0C.40006@redhat.com>
 <564CEF5D.3080005@profihost.ag> <564D9A17.6080305@redhat.com>
 <564D9B21.302@profihost.ag> <564D9CE6.2090104@profihost.ag>
 <1447933294.1974772.444210441.67F1AC5E@webmail.messagingengine.com>
 <564DB5F5.9060208@profihost.ag>
 <1447936902.1986892.444251921.3928A049@webmail.messagingengine.com>
 <564DC4A5.70104@profihost.ag> <564DCC4C.1090009@redhat.com>
 <564E2852.8000200@profihost.ag> <56530A42.6030609@profihost.ag>
 <1448283451.4019628.447573353.3659E447@webmail.messagingengine.com>
 <565EBDC1.1090808@profihost.ag> <565F2726.2080300@pmhahn.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Philipp Hahn <pmhahn@pmhahn.de>,
	"Stefan Priebe - Profihost AG" <s.priebe@profihost.ag>,
	Florian Weimer <fweimer@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <565F2726.2080300@pmhahn.de>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Wed, Dec 2, 2015, at 18:15, Philipp Hahn wrote:
> Hi,
> 
> Am 02.12.2015 um 10:45 schrieb Stefan Priebe - Profihost AG:
> > here are the results.
> > 
> > It works with 4.1.
> > It works with 4.2.
> > It does not work with 4.1.13.
> 
> the patches were first commitet in v4.3-rc3 and appear as backports only
> since v4.2.3 and v4.1.10
> 
> > git bisect tells me it stopped working after those two commits were applied:
> > 
> > commit d48623677191e0f035d7afd344f92cf880b01f8e
> > Author: Herbert Xu <herbert@gondor.apana.org.au>
> > Date:   Tue Sep 22 11:38:56 2015 +0800
> > 
> >     netlink: Replace rhash_portid with bound
> > 
> > commit 4e27762417669cb459971635be550eb7b5598286
> > Author: Herbert Xu <herbert@gondor.apana.org.au>
> > Date:   Fri Sep 18 19:16:50 2015 +0800
> > 
> >     netlink: Fix autobind race condition that leads to zero port ID
> 
> I identified the same two patches for our prpblem; see mail from
> 2015-11-17 16:53 with subject "Strange PF_NETLINK NETLINK_ROUTE stall:
> netlink: Fix autobind race condition that leads to zero port ID"
> 
> <http://marc.info/?l=linux-kernel&m=144863837825887&w=2>

Thanks, I missed this mail. I have a further look. I couldn't reproduce
it myself but will check if your test program does it.

Thanks a lot,
Hannes
