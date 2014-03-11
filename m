From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: RE: [PATCH net-next 1/5] vxlan: Make VXLAN default UDP port number
 available for others
Date: Tue, 11 Mar 2014 05:37:44 +0000
Message-ID: <262CB373A6D1F14F9B81E82F74F77D5A46F797D4@avmb2.qlogic.org>
References: <1394470142-13992-1-git-send-email-shahed.shaikh@qlogic.com>
	<1394470142-13992-2-git-send-email-shahed.shaikh@qlogic.com>
 <20140310124303.165fc8b3@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dept-HSG Linux NIC Dev <Dept-HSGLinuxNICDev@qlogic.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:47847 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752514AbaCKFhu convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Mar 2014 01:37:50 -0400
In-Reply-To: <20140310124303.165fc8b3@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Tuesday, March 11, 2014 1:13 AM
> To: Shahed Shaikh
> Cc: David Miller; netdev; Dept-HSG Linux NIC Dev
> Subject: Re: [PATCH net-next 1/5] vxlan: Make VXLAN default UDP port
> number available for others
> 
> On Mon, 10 Mar 2014 12:48:58 -0400
> Shahed Shaikh <shahed.shaikh@qlogic.com> wrote:
> 
> > From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> >
> > Although vxlan module has capability to notify udp ports to other
> > interested net devices using .ndo_add_rx_vxlan_port and
> > .ndo_del_rx_vxlan_port, there could be some devices which support
> > vxlan offload but not interested in updating udp port numbers.
> > This may be because some hardware do not support programming multiple
> > udp ports and their drivers may decide to program only default udp
> > port into adapter. So that adapter, at least, can do offloading for
> > default udp port number.
> >
> > Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
> 
> Rather than compiling in the value, it makes more sense to make the default
> port variable in vxlan driver exported. That way if user overrides it with a
> module parameter the offload will still work.

Makes sense. I will re-spin this patch to export default port variable. Thanks for the feedback.

Thanks,
Shahed
