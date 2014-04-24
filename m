From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH V1 net-next 1/1] hyperv: Enable sendbuf mechanism on the
 send path
Date: Thu, 24 Apr 2014 22:06:24 +0000
Message-ID: <cdb70820bcd0467586ce6893753c7065@BY2PR03MB299.namprd03.prod.outlook.com>
References: <1398288285-16268-1-git-send-email-kys@microsoft.com>
 <CAJUuVQ7V+Se0auKdaiqPZr8i2WcNqWhHUwz8r85DKKCjnjtrvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 LKML <linux-kernel@vger.kernel.org>, "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Andev <debiandev@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <CAJUuVQ7V+Se0auKdaiqPZr8i2WcNqWhHUwz8r85DKKCjnjtrvQ@mail.gmail.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Andev [mailto:debiandev@gmail.com]
> Sent: Thursday, April 24, 2014 2:50 PM
> To: KY Srinivasan
> Cc: davem@davemloft.net; netdev@vger.kernel.org; LKML;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> jasowang@redhat.com
> Subject: Re: [PATCH V1 net-next 1/1] hyperv: Enable sendbuf mechanism on
> the send path
> 
> On Wed, Apr 23, 2014 at 5:24 PM, K. Y. Srinivasan <kys@microsoft.com>
> wrote:
> 
> >  drivers/net/hyperv/hyperv_net.h |   14 +++
> >  drivers/net/hyperv/netvsc.c     |  226
> +++++++++++++++++++++++++++++++++++++--
> >  drivers/net/hyperv/netvsc_drv.c |    3 +->  3 files changed, 234
> insertions(+), 9 deletions(-)
> 
> I just looked over netvsc.c and it could definitely use a more consistent
> coding style.
> 
> Your use of goto exit/cleanup in some functions and returning directly on
> errors in others could use a cleanup. Please consider doing that while you are
> touching those files.

Will do. The most recent changes I made to netvsc.c, I think was consistent with the existing code;
going forward we will certainly move towards a more consistent coding style.

Regards,

K. Y
