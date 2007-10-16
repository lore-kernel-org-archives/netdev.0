From: "Yakov Lerner" <iler.ml@gmail.com>
Subject: NF_IP_POST_ROUTING hook question (2.4)
Date: Tue, 16 Oct 2007 14:03:39 +0200
Message-ID: <f36b08ee0710160503i78a7f102y762002b40dac9845@mail.gmail.com>
References: <f36b08ee0710160328h3a45d18k41a32dcb8f6f3d4e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.236]:20820 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751712AbXJPMDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 08:03:40 -0400
Received: by nz-out-0506.google.com with SMTP id s18so1197150nze
        for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 05:03:40 -0700 (PDT)
In-Reply-To: <f36b08ee0710160328h3a45d18k41a32dcb8f6f3d4e@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the NF_IP_POST_ROUTING hook function, how can I
tell that packet originated locally vs was forwarded ?
I need to hook NF_IP_POST_ROUTING not NF_IP_FORWARD.

I'd expect that 'net_device *in' argument to be  not NULL for
forwarded packets.

But what I see is NULL for both forwarded  and locally sent packets
(in NF_IP_POST_ROUTING hook).
Which field of skb can  tell me that packet originated locally ?

Yakov
