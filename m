From: Dmitriy Monakhov <dmonakhov@sw.ru>
Subject: Re: [PATCH 1/5]  fixing errors handling during pci_driver resume stage [net]
Date: Wed, 10 Jan 2007 14:11:58 +0300
Message-ID: <878xgb5e69.fsf@sw.ru>
References: <87vejgmv51.fsf@sw.ru> <20070109103530.2f10f823@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitriy Monakhov <dmonakhov@openvz.org>,
	linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	devel@openvz.org, linux-pci@atrey.karlin.mff.cuni.cz,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:9013 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964851AbXAJLL5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 06:11:57 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20070109103530.2f10f823@freekitty> (Stephen Hemminger's message of "Tue, 9 Jan 2007 10:35:30 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> writes:

> On Tue, 09 Jan 2007 12:01:14 +0300
> Dmitriy Monakhov <dmonakhov@openvz.org> wrote:
>
>> network pci drivers have to return correct error code during resume stage in
>> case of errors.
>> Signed-off-by: Dmitriy Monakhov <dmonakhov@openvz.org>
>> -----
>
> Please don't introduce one dev_err() call into a device driver if all the other
> error printout's use a different interface.
Ok. It was wrong decision to fix all affected drivers in one patchset.
Especially without respect to concrete driver specific.
I'll try to rewrite it in more slowly but (i hope) more correct way    
>
> -- 
> Stephen Hemminger <shemminger@osdl.org>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

