From: Shirley Ma <xma@us.ibm.com>
Subject: Re: [PATCH] IPv6 MIB:ipv6RouterAdvert netlink notification
Date: Thu, 15 Jan 2004 14:31:47 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFB4F51C5A.FC479F2C-ON87256E1C.007B64B8@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=08BBE48FDFE8E2288f9e8a93df938690918c08BBE48FDFE8E228"
Cc: mashirle@us.ibm.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=08BBE48FDFE8E2288f9e8a93df938690918c08BBE48FDFE8E228
Content-type: text/plain; charset=US-ASCII





This patch is going to be used by SNMP for ipv6RouterAdvert Table. I will
remove this Micro, and resubmit the patch.

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228



"David S. Miller" <davem@redhat.com> on 01/15/2004 12:52:52 AM

To:    mashirle@us.ltcfwd.linux.ibm.com
cc:    kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, Shirley
       Ma/Beaverton/IBM@IBMUS
Subject:    Re: [PATCH] IPv6 MIB:ipv6RouterAdvert netlink notification


On Wed, 14 Jan 2004 15:52:51 -0800
Shirley Ma <mashirle@us.ibm.com> wrote:

> Once receiving a router advertisement message,
> a netlink notification event will be created.
>
> This patch is against linux-2.6.1.

This patch looks fine, except I can't see how RTM_GETRA is used anywhere.
Even if it will be used by some future change, please remove it until that
later change is made.

So please either show where RTM_GETRA is used or regenerate the patch with
that macro definition removed.

Thanks.


--0__=08BBE48FDFE8E2288f9e8a93df938690918c08BBE48FDFE8E228
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>This patch is going to be used by SNMP for ipv6RouterAdvert Table. I will remove this Micro, and resubmit the patch.<br>
<br>
Thanks<br>
Shirley Ma<br>
IBM Linux Technology Center<br>
15300 SW Koll Parkway<br>
Beaverton, OR 97006-6063<br>
Phone: (503) 578-7638<br>
FAX:      (503) 578-3228<br>
<br>
<br>

<p><font size="2" color="#800080">To:	</font><font size="2">mashirle@us.ltcfwd.linux.ibm.com</font><br>
<font size="2" color="#800080">cc:	</font><font size="2">kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, Shirley Ma/Beaverton/IBM@IBMUS</font><font size="2" color="#800080"> </font><br>
<font size="2" color="#800080">Subject:	</font><font size="2">Re: [PATCH] IPv6 MIB:ipv6RouterAdvert netlink notification</font><br>
<br>
<br>
<font face="Courier New">On Wed, 14 Jan 2004 15:52:51 -0800<br>
Shirley Ma &lt;mashirle@us.ibm.com&gt; wrote:<br>
<br>
&gt; Once receiving a router advertisement message,<br>
&gt; a netlink notification event will be created.<br>
&gt; <br>
&gt; This patch is against linux-2.6.1.<br>
<br>
This patch looks fine, except I can't see how RTM_GETRA is used anywhere.<br>
Even if it will be used by some future change, please remove it until that<br>
later change is made.<br>
<br>
So please either show where RTM_GETRA is used or regenerate the patch with<br>
that macro definition removed.<br>
<br>
Thanks.<br>
</font><br>
<br>
</body></html>
--0__=08BBE48FDFE8E2288f9e8a93df938690918c08BBE48FDFE8E228--
