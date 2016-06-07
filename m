From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH v4] r8152: Add support for setting pass through MAC address on RTL8153-AD
Date: Tue, 7 Jun 2016 13:59:11 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2FF1F92@RTITMBSV03.realtek.com.tw>
References: <1465233569-13585-1-git-send-email-mario_limonciello@dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Linux USB <linux-usb@vger.kernel.org>,
	"pali.rohar@gmail.com" <pali.rohar@gmail.com>,
	"anthony.wong@canonical.com" <anthony.wong@canonical.com>,
	Greg KH <gregkh@linuxfoundation.org>
To: Mario Limonciello <mario_limonciello@dell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465233569-13585-1-git-send-email-mario_limonciello@dell.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mario Limonciello [mailto:mario_limonciello@dell.com]
[...]
> +		ret = hex2bin(buf, obj->string.pointer + 9, 6);
> +		if (ret < 0 || !is_valid_ether_addr(buf)) {
> +			netif_warn(tp, probe, tp->netdev, "Invalid MAC\n");
> +			goto amacout;
> +		}

If hex2bin() is success, the ret would be 0.
And you would return 0 when !is_valid_ether_addr(buf) occurs.
I don't think it is what you wants.

Best Regards,
Hayes
