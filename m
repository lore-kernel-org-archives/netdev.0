From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH V5 net-next 2/3] net: huawei_cdc_ncm: Introduce the
 huawei_cdc_ncm driver
Date: Mon, 04 Nov 2013 10:17:38 +0100
Message-ID: <1383556658.23830.2.camel@linux-fkkt.site>
References: <1380516609-31242-1-git-send-email-mrkiko.rs@gmail.com>
	 <1380516609-31242-3-git-send-email-mrkiko.rs@gmail.com>
	 <1380532073.1484.15.camel@linux-fkkt.site> <87fvrgwe0e.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Enrico Mioso <mrkiko.rs@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	Robert de Vries <rhdv@xs4all.nl>,
	Hayes Wang <hayeswang@realtek.com>,
	Freddy Xin <freddy@asix.com.tw>,
	Liu Junliang <liujunliang_ljl@163.com>,
	open list <linux-kernel@vger.kernel.org>,
	"open list:USB NETWORKING DR..." <linux-usb@vger.kernel.org>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	ModemManager-devel@lists.freedesktop.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87fvrgwe0e.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-11-01 at 12:35 +0100, Bj=C3=B8rn Mork wrote:

> So I believe we should do the update unconditionally, and but skip
> usb_autopm_put_interface if the get failed.  Accordingly, these
> functions should always return 0 (not that there is anything currentl=
y
> checking the return anyway).
>=20
> I'll prepare patches for cdc-wdm, qmi_wwan and cdc_mbim.

Good plan.

	Regards
		Oliver
