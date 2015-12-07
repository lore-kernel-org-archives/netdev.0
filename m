From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC PATCH net] vxlan: fix incorrect RCO bit in VXLAN header
Date: Mon, 7 Dec 2015 16:46:08 +0100
Message-ID: <20151207154608.GB22032@pox.localdomain>
References: <67179e9385c71f7c377a7df345d445704f49dbbc.1449233631.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Tom Herbert <therbert@google.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:34765 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933410AbbLGPqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 10:46:10 -0500
Received: by wmvv187 with SMTP id v187so172751407wmv.1
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 07:46:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <67179e9385c71f7c377a7df345d445704f49dbbc.1449233631.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/15 at 01:54pm, Jiri Benc wrote:
> Commit 3511494ce2f3d ("vxlan: Group Policy extension") changed definition of
> VXLAN_HF_RCO from 0x00200000 to BIT(24). This is obviously incorrect. It's
> also in violation with the RFC draft.
> 
> Fixes: 3511494ce2f3d ("vxlan: Group Policy extension")
> Cc: Thomas Graf <tgraf@suug.ch>
> Cc: Tom Herbert <therbert@google.com>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Thanks for fixing this up Jiri. Sorry about the mess Tom.
