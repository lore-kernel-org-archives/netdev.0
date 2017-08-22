From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv3 iproute2 net-next] gre: add support for ERSPAN tunnel
Date: Mon, 21 Aug 2017 21:10:28 -0700
Message-ID: <20170821211028.080ec7c9@xeon-e3>
References: <1503060848-42034-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Meenakshi Vohra <mvohra@vmware.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35082 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751136AbdHVEKb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 00:10:31 -0400
Received: by mail-pf0-f169.google.com with SMTP id w127so11382243pfd.2
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 21:10:31 -0700 (PDT)
In-Reply-To: <1503060848-42034-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Aug 2017 05:54:08 -0700
William Tu <u9012063@gmail.com> wrote:

> The patch adds ERSPAN type II tunnel support.  The implementation
> is based on the draft at https://tools.ietf.org/html/draft-foschiano-erspan-01
> One of the purposes is for Linux box to be able to receive ERSPAN
> monitoring traffic sent from the Cisco switch, by creating a ERSPAN
> tunnel device.  In addition, the patch also adds ERSPAN TX, so traffic
> can also be encapsulated into ERSPAN and sent out.
> 
> The implementation reuses the key as ERSPAN session ID, and
> field 'erspan' as ERSPAN Index fields:
> ./ip link add dev ers11 type erspan seq key 100 erspan 123 \
> 		local 172.16.1.200 remote 172.16.1.100
> 
> Signed-off-by: William Tu <u9012063@gmail.com>
> Signed-off-by: Meenakshi Vohra <mvohra@vmware.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>

Waiting until ERSPAN is upstream in kernel (net-next).
