From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net-next 0/2] ethernet: intel: Support Hyper-V hosts
Date: Fri, 15 Apr 2016 02:51:29 +0000
Message-ID: <SN2PR03MB1919A09CCC5A47893DF88BBCA0680@SN2PR03MB1919.namprd03.prod.outlook.com>
References: <1460678121-30308-1-git-send-email-kys@microsoft.com>
 <CAL3LdT4c5nhxeOrWcCPfGXAJVx2iWyjjMik6aaF3V-STBRXo0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>, netdev <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 LKML <linux-kernel@vger.kernel.org>, "jackm@mellanox.com" <jackm@mellanox.com>,
 "yevgenyp@mellanox.com" <yevgenyp@mellanox.com>, "Ronciak,
 John" <john.ronciak@intel.com>,
 intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
 "eli@mellanox.com" <eli@mellanox.com>, "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 David Miller <davem@davemloft.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <CAL3LdT4c5nhxeOrWcCPfGXAJVx2iWyjjMik6aaF3V-STBRXo0A@mail.gmail.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: tarbal@gmail.com [mailto:tarbal@gmail.com] On Behalf Of Jeff Kirsher
> Sent: Thursday, April 14, 2016 7:21 PM
> To: KY Srinivasan <kys@microsoft.com>
> Cc: David Miller <davem@davemloft.net>; netdev
> <netdev@vger.kernel.org>; LKML <linux-kernel@vger.kernel.org>;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> jasowang@redhat.com; eli@mellanox.com; jackm@mellanox.com;
> yevgenyp@mellanox.com; Ronciak, John <john.ronciak@intel.com>; intel-
> wired-lan@linuxonhyperv.com
> Subject: Re: [PATCH net-next 0/2] ethernet: intel: Support Hyper-V hosts
> 
> On Thu, Apr 14, 2016 at 4:55 PM, K. Y. Srinivasan <kys@microsoft.com>
> wrote:
> > Make adjustments to the Intel 10G VF driver to support
> > running on Hyper-V hosts.
> >
> > K. Y. Srinivasan (2):
> >   ethernet: intel: Add the device ID's presented while running on
> >     Hyper-V
> >   intel: ixgbevf: Support Windows hosts (Hyper-V)
> >
> >  drivers/net/ethernet/intel/ixgbevf/defines.h      |    5 +
> >  drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   11 ++
> >  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   56 ++++++---
> >  drivers/net/ethernet/intel/ixgbevf/mbx.c          |   12 ++
> >  drivers/net/ethernet/intel/ixgbevf/vf.c           |  138
> +++++++++++++++++++++
> >  drivers/net/ethernet/intel/ixgbevf/vf.h           |    2 +
> >  6 files changed, 206 insertions(+), 18 deletions(-)
> 
> Don't know how you butchered the mailing list address, but you did not
> send this series to intel-wired-lan@lists.osuosl.org mailing list.
> Please address the requested changes that Mark suggested and resubmit
> to the correct mailing list please.

Will do.

Thanks,

K. Y
