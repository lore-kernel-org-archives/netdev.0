From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Wed, 11 Jun 2008 21:05:57 +0200
Message-ID: <f4845fc0806111205j36c912d3vf1b632a3d0777a1c@mail.gmail.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
	 <48500A0D.5020304@trash.net>
	 <f4845fc0806111123r108348d3s6906bf2b7145bdea@mail.gmail.com>
	 <48501C81.6010800@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:33544 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753132AbYFKTGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 15:06:10 -0400
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id m5BJ5x17005233
	for <netdev@vger.kernel.org>; Wed, 11 Jun 2008 20:05:59 +0100
Received: from wf-out-1314.google.com (wfc28.prod.google.com [10.142.3.28])
	by spaceape10.eur.corp.google.com with ESMTP id m5BJ5wdr004544
	for <netdev@vger.kernel.org>; Wed, 11 Jun 2008 20:05:58 +0100
Received: by wf-out-1314.google.com with SMTP id 28so3270841wfc.20
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2008 12:05:57 -0700 (PDT)
In-Reply-To: <48501C81.6010800@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 11, 2008 at 8:42 PM, Patrick McHardy <kaber@trash.net> wrote:
> Julius Volz wrote:
>> Another question I was unsure about: is the breaking of the
>> userspace-to-kernel interface even acceptable at all? I think the code
>> would get ugly (and have even more duplication) if you wanted to keep
>> the backwards compatibility. And you have to compile ipvsadm for your
>> kernel version anyways.
>
> Usually its not acceptable. Why do you have compile ipvsadm
> for specific kernel versions?

ipvsadm uses get/set-sockopts on a raw socket to pass commands and
structs (as defined in include/net/ip_vs.h) to the kernel. So the
passed structs have to match exactly between userspace and kernel. The
kernel ip_vs.h also includes a version number that is used to verify
that ipvsadm matches your kernel version.

Julius

-- 
Google Switzerland GmbH
