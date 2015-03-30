From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net-next 1/2] hv_netvsc: Cleanup the test for freeing skb
 when we use sendbuf mechanism
Date: Mon, 30 Mar 2015 14:25:55 +0000
Message-ID: <BY2PR0301MB07115BAF22823E489A268814A0F50@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <1427688478-27950-1-git-send-email-kys@microsoft.com>
 <1427688522-27991-1-git-send-email-kys@microsoft.com>
 <20150330090234.GC10964@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20150330090234.GC10964@mwanda>
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
> From: Dan Carpenter [mailto:dan.carpenter@oracle.com]
> Sent: Monday, March 30, 2015 2:03 AM
> To: KY Srinivasan
> Cc: davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com
> Subject: Re: [PATCH net-next 1/2] hv_netvsc: Cleanup the test for freeing
> skb when we use sendbuf mechanism
> 
> On Sun, Mar 29, 2015 at 09:08:41PM -0700, K. Y. Srinivasan wrote:
> > In preparation for embedding the rndis state and other packet state into
> > the skb, cleanup the test for freeing the skb.
> >
> 
> So there is no behavior change in applying this patch?

No. When we send the packet through sendbuf, we will free up the skb after we
copy the data. The test used in the send path can also be used in the send complete path.
That is what I have done.

K. Y
> 
> regards,
> dan carpenter
