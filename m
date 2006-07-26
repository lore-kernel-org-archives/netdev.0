From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: Is the qla3xxx driver in the mainline?
Date: Wed, 26 Jul 2006 16:20:22 +0400
Message-ID: <44C75E06.1060402@tls.msk.ru>
References: <44C6E546.8030502@tw.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:38496 "EHLO hobbit.corpit.ru")
	by vger.kernel.org with ESMTP id S1750739AbWGZMU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 08:20:26 -0400
To: albertl@mail.com
In-Reply-To: <44C6E546.8030502@tw.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Albert Lee wrote:
[]
> (I am curious to have some performance comparison of
> qla3xxx + open iscsi v.s. qla4xxx + on board TOE/iscsi.)

On wich card?  I've been told that IPS4010 for example
isn't supported by qla3xxx.

BTW, I found qla4xxx (on IPS4010) performs noticeable
worse than open-iscsi stack on top of tigon (non-jumbo-
frames-capable) GigE NIC (on an eserver xSeries 346
machine).

/mjt
