From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6 MIB:ipv6RouterAdvert netlink notification
Date: Sat, 17 Jan 2004 05:23:48 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040117.052348.44213733.yoshfuji@linux-ipv6.org>
References: <OF6E7E4DFA.6824D151-ON87256E1D.006A89B5@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, mashirle@us.ibm.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: xma@us.ibm.com
In-Reply-To: <OF6E7E4DFA.6824D151-ON87256E1D.006A89B5@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OF6E7E4DFA.6824D151-ON87256E1D.006A89B5@us.ibm.com> (at Fri, 16 Jan 2004 11:41:59 -0800), Shirley Ma <xma@us.ibm.com> says:

> Yes. radvd should provide all these information. But radvd doesn't support
> this right now. I talked to someone who is patching SNMP to support new IP
> MIBs, he said it's better to support this through netlink, since netlink
> supports all other MIBs. Does netlink support user-user communication?

Yes, netlink is one option and is possibly a good candidate.
I believe netlink supports user-user communication and 
rtadvd can use it to provide information to other entities.

> Anyway I will talk to radvd maintainers to ask them to support this if you
> think this netlink notification is not needed.

I do not think netlink RA notification is required in kernel.
What you (or the radvd maintainer) need to do is to 
allocate some constants and structures for the message.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
