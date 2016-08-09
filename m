From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v2 02/14] net: ethernet: ti: cpsw: remove redundant check
 in napi poll
Date: Tue, 9 Aug 2016 13:43:39 +0530
Message-ID: <cf2bd87a-d5e7-f364-aaaf-71f4f5b5a470@ti.com>
References: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1470480524-6851-3-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<dlide@ti.com>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	<netdev@vger.kernel.org>, <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:39149 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751277AbcHIINp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2016 04:13:45 -0400
In-Reply-To: <1470480524-6851-3-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 06 August 2016 04:18 PM, Ivan Khoronzhuk wrote:
> No need to check number of handled packets, when in most cases (> 99%)
> it's not 0. It can be 0 only in rare cases, even in this case
> it's not bad to print just 0.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
