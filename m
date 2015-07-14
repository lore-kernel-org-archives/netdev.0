From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net] rtnetlink: reject non-IFLA_VF_PORT attributes inside
 IFLA_VF_PORTS
Date: Tue, 14 Jul 2015 07:49:24 -0700
Message-ID: <55A52174.1040600@cumulusnetworks.com>
References: <b6917238569c4f53d4516b71b8206e8d02e2ac21.1436736717.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Scott Feldman <sfeldma@gmail.com>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35153 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892AbbGNOt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 10:49:26 -0400
Received: by pactm7 with SMTP id tm7so6923948pac.2
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 07:49:26 -0700 (PDT)
In-Reply-To: <b6917238569c4f53d4516b71b8206e8d02e2ac21.1436736717.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/12/15, 3:06 PM, Daniel Borkmann wrote:
> Similarly as in commit 4f7d2cdfdde7 ("rtnetlink: verify IFLA_VF_INFO
> attributes before passing them to driver"), we have a double nesting
> of netlink attributes, i.e. IFLA_VF_PORTS only contains IFLA_VF_PORT
> that is nested itself. While IFLA_VF_PORTS is a verified attribute
> from ifla_policy[], we only check if the IFLA_VF_PORTS container has
> IFLA_VF_PORT attributes and then pass the attribute's content itself
> via nla_parse_nested(). It would be more correct to reject inner types
> other than IFLA_VF_PORT instead of continuing parsing and also similarly
> as in commit 4f7d2cdfdde7, to check for a minimum of NLA_HDRLEN.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
> Cc: Scott Feldman <sfeldma@gmail.com>
> Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
