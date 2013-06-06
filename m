From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 02/10] vxlan: handle skb_clone failure
Date: Thu, 6 Jun 2013 08:47:49 +0800
Message-ID: <CAM_iQpX-RY585=DszU7dURFSFKNhcyDcVLVqDrTxtLep1o_8vw@mail.gmail.com>
References: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
	<1370406254-6341-2-git-send-email-stephen@networkplumber.org>
	<komnlc$ma8$2@ger.gmane.org>
	<OF0B8CEFF8.C94A266F-ON85257B81.004D331F-85257B81.004D7015@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:43223 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755295Ab3FFArw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 20:47:52 -0400
In-Reply-To: <OF0B8CEFF8.C94A266F-ON85257B81.004D331F-85257B81.004D7015@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 5, 2013 at 10:05 PM, David Stevens <dlstevens@us.ibm.com> wrote:
> netdev-owner@vger.kernel.org wrote on 06/05/2013 02:59:56 AM:
>
>> From: Cong Wang <xiyou.wangcong@gmail.com>
>> If OOM, shouldn't we exit immediately instead of continue handle the
>> next one?
>
> It could be a temporary condition; trying again doesn't really hurt,
> in case some do go through. So, I prefer this, but could live with
> bailing for all destinations, too.
>

The problem we don't know if it is temporary or not, unless mm provides
EAGAIN?
