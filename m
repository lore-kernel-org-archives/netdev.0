From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [RFC net-next 1/2] net: allow user to set IPv6 nexthop for IPv4
 route
Date: Fri, 27 Mar 2015 11:53:01 +0000
Message-ID: <5515449D.4080408@brocade.com>
References: <1427403928-1342-1-git-send-email-gospo@cumulusnetworks.com> <1427403928-1342-2-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
To: Andy Gospodarek <gospo@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Bjornar Ness <bjornar.ness@gmail.com>,
	"Sowmini Varadhan" <sowmini05@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:46550 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752613AbbC0Lzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 07:55:38 -0400
In-Reply-To: <1427403928-1342-2-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/03/15 21:05, Andy Gospodarek wrote:
> diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
> index bea910f..26cdd01 100644
> --- a/include/uapi/linux/rtnetlink.h
> +++ b/include/uapi/linux/rtnetlink.h
> @@ -306,6 +306,7 @@ enum rtattr_type_t {
>          RTA_VIA,
>          RTA_NEWDST,
>          RTA_PREF,
> +       RTA_GATEWAY6,

There shouldn't be any need to add a new attribute. The RTA_VIA 
attribute that Eric Biederman recently introduced should have the 
semantics that you require:

"RTA_VIA specifies the specifies the next machine to send a packet to
like RTA_GATEWAY.  RTA_VIA differs from RTA_GATEWAY in that it
includes the address family of the address of the next machine to send
a packet to."

Thanks,
Rob
