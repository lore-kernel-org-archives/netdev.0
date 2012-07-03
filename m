From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 00/13] drivers: hv: kvp
Date: Tue, 3 Jul 2012 15:35:23 +0000
Message-ID: <426367E2313C2449837CD2DE46E7EAF9155EF804@SN2PRD0310MB382.namprd03.prod.outlook.com>
References: <20120703132049.GA10663@aepfle.de>
 <642e6af6-fc6b-4c54-a4a6-f5bdd38512c7@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "apw@canonical.com" <apw@canonical.com>,
 Greg KH <gregkh@linuxfoundation.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>, Olaf Hering
 <olaf@aepfle.de>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <642e6af6-fc6b-4c54-a4a6-f5bdd38512c7@tahiti.vyatta.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen.hemminger@vyatta.com]
> Sent: Tuesday, July 03, 2012 11:03 AM
> To: Olaf Hering
> Cc: Greg KH; apw@canonical.com; devel@linuxdriverproject.org; linux-
> kernel@vger.kernel.org; netdev@vger.kernel.org; KY Srinivasan
> Subject: Re: [PATCH 00/13] drivers: hv: kvp
> 
> 
> > On Mon, Jul 02, KY Srinivasan wrote:
> >
> > > While I toyed with your proposal, I feel it just pushes the problem
> > > out of the daemon code - we would still need to write distro
> > > specific
> > > scripts. If this approach is something that everybody is
> > > comfortable
> > > with, I can take a stab at implementing that.
> >
> > Until NetworkManager is feature complete and until every distro is
> > using
> > NetworkManager per default the kvp_daemon needs distro specific code
> > to
> > get and set network related settings.
> > Doing it with an external script will simplify debugging and changes
> > to
> > the code.
> 
> Although,  Network Manager is a good tool for what it does;
> it is not appropriate for every distro. It is overkill
> in embedded systems, and it's GUI dependency makes it unmanageable
> on servers.

Thanks Stephen. I will retain the code that I currently have for the "GET" side and
I will implement a script as Olaf suggested that can be distro specific to implement
the SET operation.

Regards,

K. Y
