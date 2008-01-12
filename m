From: "Ian Brown" <ianbrn@gmail.com>
Subject: What is XFRM_POLICY_LOCALOK for?
Date: Sat, 12 Jan 2008 10:31:41 +0200
Message-ID: <d0383f90801120031r142b2be1taee5efd190768407@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:26241 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754161AbYALIbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 03:31:45 -0500
Received: by py-out-1112.google.com with SMTP id u52so2063109pyb.10
        for <netdev@vger.kernel.org>; Sat, 12 Jan 2008 00:31:42 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

 I tried to understand what XFRM_POLICY_LOCALOK is for. (include/linux/xfrm.h)
It is defined thus:
 #define XFRM_POLICY_LOCALOK	1	/* Allow user to override global policy */

is it part of flags of xfrm_userpolicy_info?? I doubt this, since we have
above flags two defines:

#define XFRM_POLICY_ALLOW	0
#define XFRM_POLICY_BLOCK	1


Moreover, both XFRM_POLICY_BLOCK and XFRM_POLICY_LOCALOK has a vlaue of 1.

I could not see any usage for XFRM_POLICY_LOCALOK in kernel code.

Regards,
Ian B
