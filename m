From: Martin Lau <kafai@fb.com>
Subject: Re: A problem about ICMP packet-too-big message handler
Date: Tue, 27 Jan 2015 21:19:29 -0800
Message-ID: <20150128051929.GA3369592@devbig242.prn2.facebook.com>
References: <54C78B8D.1070104@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58674 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762573AbbA1FTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 00:19:48 -0500
Content-Disposition: inline
In-Reply-To: <54C78B8D.1070104@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2015 at 08:58:53PM +0800, Yang Yingliang wrote:
> Hi,
> 
> My kernel is 3.10 LTS.
> 
> I got a problem here about handling ICMP packet-too-big message.
> 
> Before sending a packet-too-big packet :
The expires should be set by the host _receiving_ the icmpv6 too-big.

Can you spell out some details of the outgoing icmpv6 too-big packet?
like, the src/dst ip of the icmpv6 and the original ip packet that triggered the
too-big.
