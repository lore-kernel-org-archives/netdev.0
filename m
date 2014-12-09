From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH] netback: don't store invalid vif pointer
Date: Tue, 9 Dec 2014 12:08:25 +0000
Message-ID: <1418126905.14361.30.camel@eu.citrix.com>
References: <5486EF48020000780004E1B8@mail.emea.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	xen-devel <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:61786 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755999AbaLIMI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 07:08:28 -0500
In-Reply-To: <5486EF48020000780004E1B8@mail.emea.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-09 at 11:47 +0000, Jan Beulich wrote:
> When xenvif_alloc() fails, it returns a non-NULL error indicator. To
> avoid eventual races, we shouldn't store that into struct backend_info
> as readers of it only check for NULL.
> 
> Signed-off-by: Jan Beulich <jbeulich@suse.com>

Acked-by: Ian Campbell <ian.campbell@citrix.com>

Thanks.
