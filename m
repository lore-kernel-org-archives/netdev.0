From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net-next V2 08/17] hv_netvsc: Don't ask for additional
 head room in the skb
Date: Tue, 1 Dec 2015 20:48:03 +0000
Message-ID: <BY2PR0301MB16543B087ABDCADFA618AB9BA00F0@BY2PR0301MB1654.namprd03.prod.outlook.com>
References: <1448742017-22693-1-git-send-email-kys@microsoft.com>
	<1448742045-22732-1-git-send-email-kys@microsoft.com>
	<1448742045-22732-8-git-send-email-kys@microsoft.com>
 <20151201.154147.1720863076099915966.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151201.154147.1720863076099915966.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, December 1, 2015 12:42 PM
> To: KY Srinivasan <kys@microsoft.com>
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> jasowang@redhat.com
> Subject: Re: [PATCH net-next V2 08/17] hv_netvsc: Don't ask for additional
> head room in the skb
> 
> From: "K. Y. Srinivasan" <kys@microsoft.com>
> Date: Sat, 28 Nov 2015 12:20:36 -0800
> 
> > +#elseif defined(CONFIG_WLAN) || IS_ENABLED(CONFIG_AX25)
> 
> The correct CPP directive is "#elif".

Thanks David, I will fix the typo and resubmit.

K. Y
