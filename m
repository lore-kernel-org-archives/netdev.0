From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net-next 1/1] hv_netvsc: Use the xmit_more skb flag to
 optimize signaling the host
Date: Thu, 30 Apr 2015 20:37:38 +0000
Message-ID: <BY2PR0301MB0711597E1A28FC78BB6533C8A0D60@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <1430346822-13103-1-git-send-email-kys@microsoft.com>
 <20150430.163517.1578100484032071517.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20150430.163517.1578100484032071517.davem@davemloft.net>
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
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, April 30, 2015 1:35 PM
> To: KY Srinivasan
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> jasowang@redhat.com
> Subject: Re: [PATCH net-next 1/1] hv_netvsc: Use the xmit_more skb flag to
> optimize signaling the host
> 
> From: "K. Y. Srinivasan" <kys@microsoft.com>
> Date: Wed, 29 Apr 2015 15:33:42 -0700
> 
> > @@ -772,19 +773,21 @@ static inline int netvsc_send_pkt(
> >  	if (packet->page_buf_cnt) {
> >  		pgbuf = packet->cp_partial ? packet->page_buf +
> >  			packet->rmsg_pgcnt : packet->page_buf;
> > -		ret = vmbus_sendpacket_pagebuffer(out_channel,
> > +		ret = vmbus_sendpacket_pagebuffer_ctl(out_channel,
> >  						  pgbuf,
> 
> You have to fix the indentation of the arguments if you are going to change
> the column where the openning parenthesis occurs on the first line.

Will do.

K. Y
