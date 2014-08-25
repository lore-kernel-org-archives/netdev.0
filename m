From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 4/4] r8152: support firmware files
Date: Mon, 25 Aug 2014 03:23:06 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2516161@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-16-Taiwan-albertk@realtek.com>
 <1394712342-15778-20-Taiwan-albertk@realtek.com>
 <20140824212055.GA30857@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140824212055.GA30857@electric-eye.fr.zoreil.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu [mailto:romieu@fr.zoreil.com] 
[...]
> > +static void rtl_request_firmware(struct r8152 *tp)
> > +{
> > +	char *fw_name = NULL;
> > +
> > +	if (tp->rtl_fw.fw)
> > +		goto out_request;
> > +
> > +	switch (tp->version) {
> > +	case RTL_VER_01:
> > +		fw_name = "rtl_nic/rtl8152-1.fw";
> > +		break;
> > +	case RTL_VER_02:
> > +		fw_name = "rtl_nic/rtl8152-2.fw";
> > +		break;
> > +	case RTL_VER_03:
> > +		fw_name = "rtl_nic/rtl8153-1.fw";
> > +		break;
> > +	case RTL_VER_04:
> > +		fw_name = "rtl_nic/rtl8153-2.fw";
> > +		break;
> > +	case RTL_VER_05:
> > +		fw_name = "rtl_nic/rtl8153-3.fw";
> > +		break;
> 
> The driver should use MODULE_FIRMWARE() for these files.

Oops. I would fix this. Thanks.
 
Best Regards,
Hayes
