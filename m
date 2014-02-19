From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hyperv: Add latest NetVSP versions to auto
 negotiation
Date: Wed, 19 Feb 2014 23:00:33 +0000
Message-ID: <b31a2c984e7d4ec2aae75ae77a3bdf65@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1392755334-25884-1-git-send-email-haiyangz@microsoft.com>
 <20140219.162312.1711517042878098859.davem@davemloft.net>
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
In-Reply-To: <20140219.162312.1711517042878098859.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, February 19, 2014 4:23 PM
> To: Haiyang Zhang
> Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
> jasowang@redhat.com; linux-kernel@vger.kernel.org; driverdev-
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net-next] hyperv: Add latest NetVSP versions to auto
> negotiation
> 
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Tue, 18 Feb 2014 12:28:54 -0800
> 
> > +	u32 ver_list[] = {NVSP_PROTOCOL_VERSION_1,
> NVSP_PROTOCOL_VERSION_2,
> > +		NVSP_PROTOCOL_VERSION_4, NVSP_PROTOCOL_VERSION_5};
> 
> Please put a space after "{" and before "}".
> 
> > +	int i, num_ver = 4; /* number of different NVSP versions */
> > +
> >
> >  	net_device = get_outbound_net_device(device);
> 
> Please delete the extraneous empty line.
> 
> > +	for (i = num_ver - 1; i >= 0; i--)
> > +		if (negotiate_nvsp_ver(device, net_device, init_packet,
> > +			ver_list[i])  == 0) {
> 
> This is not indented properly, "ver_list[i])" should begin precisely after the
> openning parenthesis of the negotiate_nvsp_ver() function call.

I have sent out a new patch with the suggested updates.

Thanks,
- Haiyang
