From: "Justin P. Mattock" <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: ath9k timeouts with the current Mainline
Date: Sun, 15 Jan 2012 07:50:53 -0800
Message-ID: <4F12F5DD.3030904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

not sure if the Internet provider just sucks, or I am hitting a wireless 
issue. basically my connection times out after a few mins of being 
up.(streaming radio is not solid).

dmesg shows:

[ 3322.827549] wlan1: authenticate with d8:c7:c8:a2:0f:40 (try 1)
[ 3322.831778] wlan1: d8:c7:c8:a2:0f:40 denied authentication (status 17)
[ 3386.310128] wlan1: authenticate with d8:c7:c8:a2:0d:80 (try 1)
[ 3386.312010] wlan1: d8:c7:c8:a2:0d:80 denied authentication (status 17)
[ 3389.481771] wlan1: direct probe to 00:18:0a:02:19:c3 (try 1/3)
[ 3389.681095] wlan1: direct probe to 00:18:0a:02:19:c3 (try 2/3)
[ 3389.881094] wlan1: direct probe to 00:18:0a:02:19:c3 (try 3/3)
[ 3390.081092] wlan1: direct probe to 00:18:0a:02:19:c3 timed out
[ 3458.618065] wlan1: direct probe to d8:c7:c8:a2:0d:80 (try 1/3)
[ 3458.818079] wlan1: direct probe to d8:c7:c8:a2:0d:80 (try 2/3)
[ 3459.018080] wlan1: direct probe to d8:c7:c8:a2:0d:80 (try 3/3)
[ 3459.218058] wlan1: direct probe to d8:c7:c8:a2:0d:80 timed out
[ 3466.518579] wlan1: direct probe to d8:c7:c8:a2:0d:80 (try 1/3)
[ 3466.718111] wlan1: direct probe to d8:c7:c8:a2:0d:80 (try 2/3)
[ 3466.918074] wlan1: direct probe to d8:c7:c8:a2:0d:80 (try 3/3)
[ 3467.118077] wlan1: direct probe to d8:c7:c8:a2:0d:80 timed out
[ 3474.424860] wlan1: authenticate with d8:c7:c8:a2:0d:80 (try 1)
[ 3474.449681] wlan1: authenticated
[ 3474.457133] wlan1: associate with d8:c7:c8:a2:0d:80 (try 1)
[ 3474.471059] wlan1: RX AssocResp from d8:c7:c8:a2:0d:80 (capab=0x421 
status=0 aid=13)
[ 3474.471067] wlan1: associated
[ 3474.471075] wlan1: moving STA d8:c7:c8:a2:0d:80 to state 1
[ 3474.471080] wlan1: moving STA d8:c7:c8:a2:0d:80 to state 2
[ 3474.473809] wlan1: moving STA d8:c7:c8:a2:0d:80 to state 3
[ 3484.546077] wlan1: no IPv6 routers present


card is:
03:00.0 Network controller: Atheros Communications Inc. AR5008 Wireless 
Network Adapter (rev 01)

has anybody else seen/experienced anything like this?

Justin P. Mattock
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
