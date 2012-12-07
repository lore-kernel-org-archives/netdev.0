From: Vasanthakumar Thiagarajan <vthiagar-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: [RFC V3 1/2] I'dcfg80211: Move the definition of struct mac_address
 up
Date: Fri, 7 Dec 2012 12:26:03 +0530
Message-ID: <50C19303.5060608@qca.qualcomm.com>
References: <1354853850-10537-1-git-send-email-vthiagar@qca.qualcomm.com> <1354858735.22463.31.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1354858735.22463.31.camel@joe-AO722>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On Friday 07 December 2012 11:08 AM, Joe Perches wrote:
> On Fri, 2012-12-07 at 09:47 +0530, Vasanthakumar Thiagarajan wrote:
>> struct mac_address will be used by ACL related configuration ops.
>
> I'd prefer that any new code _not_ use struct mac_address
> but use u8 addr[ETH_ALEN] instead.
>
> That's the most common style in the kernel.

Ok, but struct mac_address looked handy when I want
to deal with list of mac address instead using linked
list. Thanks!

Vasanth
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
