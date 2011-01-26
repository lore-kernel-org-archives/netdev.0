From: "Palash Bandyopadhyay" <Palash.Bandyopadhyay@conexant.com>
Subject: RE: [RFC 00/20] Proposal for remaining BKL users
Date: Wed, 26 Jan 2011 08:24:04 -0800
Message-ID: <34B38BE41EDBA046A4AFBB591FA31132024B33E8CE@NBMBX01.bbnet.ad>
References: <1295993854-4971-1-git-send-email-arnd@arndb.de>
	<201101261231.30390.arnd@arndb.de>
	<4D400C5D.80004@redhat.com> <201101261445.17751.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Frederic Weisbecker <fweisbec@gmail.com>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
	"H. Peter Anvin" <hpa@zytor.com>, Ian Kent <raven@themaw.net>,
	"linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
	Nick Bowler <nbowler@elliptictech.com>,
	"linux-x25@vger.kernel.org" <linux-x25@vger.kernel.org>,
	Takahiro Hirofuchi <hirofuchi@users.sourceforge.net>,
	Ross Cohen <rcohen@snurgle.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Evgeniy Dushistov <dushistov@mail.ru>,
	Stuart Swales <stuart.swales.croftnuisk@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"autofs@linux.kernel.org" <autofs@linux.kernel.org>,
	Jeff Layton <jlayton@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg KH <gregkh@suse.de>,
	"linux-kernel@vger.ker
To: "Arnd Bergmann" <arnd@arndb.de>,
	"Mauro Carvalho Chehab" <mchehab@redhat.com>
Return-path: <dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org>
In-Reply-To: <201101261445.17751.arnd@arndb.de>
Content-Language: en-US
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/dri-devel>,
	<mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Sender: dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org
Errors-To: dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org
List-Id: netdev.vger.kernel.org

I think it should be ok. If we do hit any performance issue, we'll revisit this.

Thanks,
Palash

-----Original Message-----
From: Arnd Bergmann [mailto:arnd@arndb.de] 
Sent: Wednesday, January 26, 2011 5:45 AM
To: Mauro Carvalho Chehab
Cc: Greg KH; linux-kernel@vger.kernel.org; Andrew Hendry; Andrew Morton; Arjan van de Ven; Arnaldo Carvalho de Melo; autofs@linux.kernel.org; Chris Wilson; Dave Airlie; dri-devel@lists.freedesktop.org; Evgeniy Dushistov; Frederic Weisbecker; H. Peter Anvin; Ian Kent; Ingo Molnar; Jeff Layton; linux-cifs@vger.kernel.org; linux-fsdevel@vger.kernel.org; linux-x25@vger.kernel.org; Mikulas Patocka; netdev@vger.kernel.org; Nick Bowler; Palash Bandyopadhyay; Ross Cohen; Russell King; Stuart Swales; Takahiro Hirofuchi; Thomas Gleixner
Subject: Re: [RFC 00/20] Proposal for remaining BKL users

On Wednesday 26 January 2011, Mauro Carvalho Chehab wrote:
> I guess you're meaning cx25821, right? 

Right, sorry for the typo.
 
> Palash should take a look on it and review. This is a device that allows
> 12 simultaneous streams, so, I suspect that he'll need to do some
> changes at the locking schema, to avoid performance bottlenecks.

I would be surprised if there was any measurable performance change.
The BKL was used only in the open() function to iterate the device
list, and that code is nowhere on a critical path, as far as I can tell.

	Arnd

Conexant E-mail Firewall (Conexant.Com) made the following annotations
---------------------------------------------------------------------
********************** Legal Disclaimer **************************** 

"This email may contain confidential and privileged material for the sole use of the intended recipient. Any unauthorized review, use or distribution by others is strictly prohibited. If you have received the message in error, please advise the sender by reply email and delete the message. Thank you." 

********************************************************************** 

---------------------------------------------------------------------
