From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 00/17] drivers: hv: kvp
Date: Sun, 29 Jul 2012 22:50:56 +0000
Message-ID: <426367E2313C2449837CD2DE46E7EAF9236AA5A6@SN2PRD0310MB382.namprd03.prod.outlook.com>
References: <1343145672-3641-1-git-send-email-kys@microsoft.com>
 <20120724155412.GA23918@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "virtualization@lists.osdl.org" <virtualization@lists.osdl.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "ben@decadent.org.uk" <ben@decadent.org.uk>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <20120724155412.GA23918@kroah.com>
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
> From: Greg KH [mailto:gregkh@linuxfoundation.org]
> Sent: Tuesday, July 24, 2012 11:54 AM
> To: KY Srinivasan
> Cc: linux-kernel@vger.kernel.org; devel@linuxdriverproject.org;
> virtualization@lists.osdl.org; olaf@aepfle.de; apw@canonical.com;
> netdev@vger.kernel.org; ben@decadent.org.uk
> Subject: Re: [PATCH 00/17] drivers: hv: kvp
> 
> On Tue, Jul 24, 2012 at 09:01:12AM -0700, K. Y. Srinivasan wrote:
> > This patchset expands the KVP (Key Value Pair) functionality to
> > implement the mechanism to GET/SET IP addresses in the guest. This
> > functionality is used in Windows Server 2012 to implement VM
> > replication functionality. The way IP configuration information
> > is managed is distro specific. Based on the feedback I have gotten
> > from Olaf, Greg, Steve, Ben and Mairus, I have chosen to seperate
> > distro specific code from this patch-set. Most of the GET operation
> > can be implemented in a way that is completely distro independent and
> > I have implemented that as such and is included in this patch-set.
> > Some of the attributes that can only be fetched in a distro
> > dependent way as well the mechanism for configuring an interface
> > (the SET operation) that is clearly distro specific is to be
> > implemented via external scripts that will be invoked via the KVP
> > code. We define here the interface to these scripts.
> >
> > Adding support for IP injection resulted in some changes to the
> > protocol between the user level daemon and the kernel driver.
> > These changes have been implemented in way that would retain
> > compatibility with older daemons. I would like to thank Olaf and
> > Greg for pointing out the compatibility issue.
> 
> Due to this being the middle of the merge window, I will not be able to
> look at this until after 3.6-rc1 is out.

Thanks Greg. In the meantime, I have addressed all the comments that both Olaf
and Ben have posted on this patch-set. Since addressing these comments changed
some data structures, I think it will be best if you dropped this patch-set. I will post the 
updated patch-set shortly.

Regards,

K. Y
