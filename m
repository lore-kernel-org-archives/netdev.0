From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next,1/2] hyperv: Remove recv_pkt_list and lock
Date: Mon, 21 Apr 2014 21:00:52 +0000
Message-ID: <2deafebb39844bc49b22695ae2c9df86@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1398108376-4857-1-git-send-email-haiyangz@microsoft.com>
 <20140421.145711.1903592201158395025.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140421.145711.1903592201158395025.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, April 21, 2014 2:57 PM
> To: Haiyang Zhang
> Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
> jasowang@redhat.com; linux-kernel@vger.kernel.org; driverdev-
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net-next,1/2] hyperv: Remove recv_pkt_list and lock
> 
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Mon, 21 Apr 2014 12:26:15 -0700
> 
> > @@ -401,8 +401,6 @@ static void rndis_filter_receive_data(struct
> rndis_device *dev,
> >  	pkt->total_data_buflen = rndis_pkt->data_len;
> >  	pkt->data = (void *)((unsigned long)pkt->data + data_offset);
> >
> > -	pkt->is_data_pkt = true;
> > -
> >  	vlan = rndis_get_ppi(rndis_pkt, IEEE_8021Q_INFO);
> >  	if (vlan) {
> >  		pkt->vlan_tci = VLAN_TAG_PRESENT | vlan->vlanid |
> 
> This part of your change is not explained at all in your commit message.
> 
> Please resubmit this series with this hunk properly described and accounted for.

I have updated the description and re-send them.

Thanks,
- Haiyang
