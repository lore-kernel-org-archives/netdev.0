From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: ip addr flush hangs
Date: Wed, 10 Mar 2004 12:32:30 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040310.123230.86301894.yoshfuji@linux-ipv6.org>
References: <20040309152932.36a42997.davem@redhat.com>
	<OF34091B26.07758A8E-ON87256E52.00833C04-88256E53.00004022@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: okir@suse.de, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com, xma@us.ibm.com
In-Reply-To: <OF34091B26.07758A8E-ON87256E52.00833C04-88256E53.00004022@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OF34091B26.07758A8E-ON87256E52.00833C04-88256E53.00004022@us.ibm.com> (at Tue, 9 Mar 2004 15:56:00 -0800), Shirley Ma <xma@us.ibm.com> says:

> This fix causes a problem for SNMP IPv6 MIBs. It requires to dump all
> interface
> address types unicast/mcast/anycast. I would like suggest to fix the ip
> command to fix the problem.

Grr... Putting anycast/multicast is not good idea.
(Sorry, I did not notice at that time...)

Anycast should use IFA_ANYCAST ifaddrmsg instead of IFA_ADDRESS.
Multicast should be provided in a different way (different rtmsg),
or use IFA_MULTICAST or something like that.

--yoshfuji
