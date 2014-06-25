From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [PATCH 3/3] ath10k: add firmware files
Date: Wed, 25 Jun 2014 08:47:31 -0700
Message-ID: <20140625154731.GJ1390@garbanzo.do-not-panic.com>
References: <20140314084501.23100.13103.stgit@x230>
 <20140314084514.23100.72654.stgit@x230>
 <CAB=NE6WW8yX4kdy02j2fT4g0JvYj4a_XkiqYtXKZSMB7FHuwNg@mail.gmail.com>
 <1394996230.15764.113.camel@deadeye.wl.decadent.org.uk>
 <CAB=NE6UP7dAwBHWUvtqAWksbrrdJ=vBRmT2PfcJPdeNhHfb7Kw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kalle Valo <kvalo@qca.qualcomm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Woodhouse <dwmw2@infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	ath10k@lists.infradead.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAB=NE6UP7dAwBHWUvtqAWksbrrdJ=vBRmT2PfcJPdeNhHfb7Kw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 16, 2014 at 01:17:52PM -0700, Luis R. Rodriguez wrote:
> On Sun, Mar 16, 2014 at 11:57 AM, Ben Hutchings <ben@decadent.org.uk> wrote:
> > On Fri, 2014-03-14 at 05:36 -0700, Luis R. Rodriguez wrote:
> >> On Fri, Mar 14, 2014 at 1:45 AM, Kalle Valo <kvalo@qca.qualcomm.com> wrote:
> > [...]
> >> > + NO LICENSES OR OTHER RIGHTS,
> >> > +WHETHER EXPRESS, IMPLIED, BASED ON ESTOPPEL OR OTHERWISE, ARE GRANTED
> >> > +TO ANY PARTY'S PATENTS, PATENT APPLICATIONS, OR PATENTABLE INVENTIONS
> >> > +BY VIRTUE OF THIS LICENSE OR THE DELIVERY OR PROVISION BY QUALCOMM
> >> > +ATHEROS, INC. OF THE SOFTWARE.
> >>
> >> This -- however is new to linux-firmware -- and I hereby raise a big
> >> red fucking flag. All other licenses on linux-firmware provide at the
> >> very least a limited patent grant. What makes Qualcomm special ?
> > [...]
> >
> > There are several licence texts that don't mention patents at all.  I'm
> > assuming that the companies submitting firmware for inclusion in Linux
> > or linux-firmware do intend to grant whatever licences are required to
> > distribute it to end users.
> 
> Agreed, this would be the only fair thing.
> 
> > Several licence texts explicitly exclude patent licences relating to any
> > *other* products of the same company, but that's quite redundant.
> 
> Sure.
> 
> > However this language seems to explicitly exclude *any* patent licence.
> 
> Yeap, they are making it crystal clear.
> 
> > You're right to raise a red flag because, assuming Qualcomm does have
> > patents that cover the firmware alone, this seems to disallow
> > redistribution in whatever jurisdictions those patents apply.
> 
> I'm also fearful of this setting a precedent for other vendors.

<-- snip -->

> To avoid patches as this one should we define some basic guidelines
> for linux-firmware acceptable licenses?

How about this small change to clarify ?

>From b0b9bd8328f797836ce0db6157232d017220594b Mon Sep 17 00:00:00 2001
From: "Luis R. Rodriguez" <mcgrof@suse.com>
Date: Wed, 25 Jun 2014 08:41:25 -0700
Subject: [PATCH] README: clarify redistribution requirements covering patents

Firmware licenses should include an implicit or explicit
patent grant to end users for full device operation.

Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---
 README | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/README b/README
index f2ed92e..d2a56ec 100644
--- a/README
+++ b/README
@@ -18,7 +18,10 @@ and also cc: to related mailing lists.
 
 Your commit should include an update to the WHENCE file clearly
 identifying the licence under which the firmware is available, and
-that it is redistributable. If the licence is long and involved, it's
+that it is redistributable. Being redistributable includes ensuring
+the firmware license provided includes an implicit or explicit
+patent grant to end users to ensure full functionality of device
+operation with the firmware. If the licence is long and involved, it's
 permitted to include it in a separate file and refer to it from the
 WHENCE file.
 And if it were possible, a changelog of the firmware itself.
-- 
2.0.0
