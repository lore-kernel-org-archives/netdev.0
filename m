From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net 1/1] hv_netvsc: Fix a bug in netvsc_start_xmit()
Date: Tue, 28 Apr 2015 18:59:55 +0000
Message-ID: <BY2PR0301MB0711A65F2833086181B0AC4FA0E80@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <1430183690-24198-1-git-send-email-kys@microsoft.com>
 <553FD0FC.3090704@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <553FD0FC.3090704@cogentembedded.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com]
> Sent: Tuesday, April 28, 2015 11:27 AM
> To: KY Srinivasan; davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com
> Subject: Re: [PATCH net 1/1] hv_netvsc: Fix a bug in netvsc_start_xmit()
> 
> Hello.
> 
> On 04/28/2015 04:14 AM, K. Y. Srinivasan wrote:
> 
> > Commit commit b08cc79155fc26d0d112b1470d1ece5034651a4b eliminated
> memory
> 
>     One "commit" is enough. :-)
>     And please also specify that commit's summary in parens.
> 
> > allocation in the packet send path. This commit introduced a bug since it
> > did not account for the case if the skb was cloned. Fix this bug by
> > using the pre-reserved head room only if the skb is not cloned.
> 
> > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> 
> [...]
> 
> WBR, Sergei

Will do; thanks.

K. Y
