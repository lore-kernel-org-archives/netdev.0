From: Shirley Ma <xma@us.ibm.com>
Subject: Re: [PATCH]dump interface IPv6 multicast/anycast addresses through netlink
Date: Wed, 31 Mar 2004 21:18:57 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF8F6A9EBE.82E160C6-ON87256E69.001BB337-88256E69.001D33A3@us.ibm.com>
References: <20040401.135048.45446611.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=08BBE4FADF8835A78f9e8a93df938690918c08BBE4FADF8835A7"
Cc: davem@redhat.com, mashirle@us.ibm.com, netdev@oss.sgi.com,
        "Hideaki YOSHIFUJI" <yoshfuji@cerberus.hongo.wide.ad.jp>,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040401.135048.45446611.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=08BBE4FADF8835A78f9e8a93df938690918c08BBE4FADF8835A7
Content-type: text/plain; charset=US-ASCII





The reason to add these flags was for rtnetlink MATCH request through
RTM_GETADDRESS. Since here we use RTM_GETMULTICAST,
RTM_GETANYCAST for getting multicast/anycast addresses, it's not
necessary to have these flags. I will remove them.

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228

--0__=08BBE4FADF8835A78f9e8a93df938690918c08BBE4FADF8835A7
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>The reason to add these flags was for rtnetlink MATCH request through <br>
RTM_GETADDRESS. Since here we use RTM_GETMULTICAST, <br>
RTM_GETANYCAST for getting multicast/anycast addresses, it's not <br>
necessary to have these flags. I will remove them.<br>
<br>
Thanks<br>
Shirley Ma<br>
IBM Linux Technology Center<br>
15300 SW Koll Parkway<br>
Beaverton, OR 97006-6063<br>
Phone: (503) 578-7638<br>
FAX:      (503) 578-3228<br>
<br>
</body></html>
--0__=08BBE4FADF8835A78f9e8a93df938690918c08BBE4FADF8835A7--
