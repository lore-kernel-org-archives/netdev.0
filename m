From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: iputils flowlabel
Date: Thu, 17 Jun 2010 11:20:04 +0900
Message-ID: <4C198654.4050805@linux-ipv6.org>
References: <1272444708.3035.39.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Skala <jskala@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50379 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755892Ab0FQCU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 22:20:29 -0400
In-Reply-To: <1272444708.3035.39.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Skala wrote:
> I'd like to ask about current state of FLOWLABEL functionality. This is
> currently wrapped into define and disabled by default.
> 
> Trying to enable it means to define (somehow = in proprietary header)
> in6_flowlabel_req structure because usage of linux/in6.h conflicts with
> glibc's headers.
> 
> Is flowlabel fnc inside ifdef due to described 'header' issue? Any other
> comment to this topic?

Yes, that's right.

--yoshfuji

