From: Robert Gadsdon <rhgadsdon@gmail.com>
Subject: Re: [PATCH] stmmac: Fix phy without MDIO subnode
Date: Wed, 30 Mar 2016 11:22:42 -0700
Message-ID: <56FC1972.9050704@gmail.com>
References: <1458817012-14293-1-git-send-email-john@metanate.com>
 <56F3E3E2.6070001@st.com> <20160324170119.28d54ed5.john@metanate.com>
 <56F4F9F6.8070103@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Gabriel Fernandez <gabriel.fernandez@linaro.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	John Keeping <john@metanate.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56F4F9F6.8070103@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have applied this to my Rock2 - Kernel 4.6-rc1 - and eth0 is present,
now, but no network traffic gets through:

To rock2:
$ ping rgrock2
PING rgrock2 (192.168.0.xx) 56(84) bytes of data.
^C
--- rgrock2 ping statistics ---
9 packets transmitted, 0 received, 100% packet loss, time 7999ms

>From rock2:
# ping 192.168.0.x
PING 192.168.0.x (192.168.0.2) 56(84) bytes of data.
>From 192.168.0.xx icmp_seq=1 Destination Host Unreachable
>From 192.168.0.xx icmp_seq=2 Destination Host Unreachable
>From 192.168.0.xx icmp_seq=3 Destination Host Unreachable
>From 192.168.0.xx icmp_seq=4 Destination Host Unreachable
>From 192.168.0.xx icmp_seq=5 Destination Host Unreachable
>From 192.168.0.xx icmp_seq=6 Destination Host Unreachable
>From 192.168.0.xx icmp_seq=7 Destination Host Unreachable
>From 192.168.0.xx icmp_seq=8 Destination Host Unreachable

--- 192.168.0.x ping statistics ---
9 packets transmitted, 0 received, +8 errors, 100% packet loss, time 8001ms

Everything worked OK with kernel 4.5-rc7, and with 4.5 Final with the
-rc7 versions of stmmac_platform.c and stmmac_mdio.c substituted..

Robert Gadsdon. March 30, 2016
