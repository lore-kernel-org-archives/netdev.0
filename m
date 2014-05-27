From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 2/2] macvlan: slight optimization for
 macvlan_handle_frame
Date: Tue, 27 May 2014 09:58:01 -0700
Message-ID: <20140527095801.6d269c1f@nehalam.linuxnetplumber.net>
References: <1401187996-10252-1-git-send-email-dingtianhong@huawei.com>
	<1401187996-10252-3-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <kaber@trash.net>, <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:47737 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752594AbaE0Q6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 12:58:05 -0400
Received: by mail-pa0-f45.google.com with SMTP id ey11so9450857pad.4
        for <netdev@vger.kernel.org>; Tue, 27 May 2014 09:58:04 -0700 (PDT)
In-Reply-To: <1401187996-10252-3-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 May 2014 18:53:16 +0800
Ding Tianhong <dingtianhong@huawei.com> wrote:

> Add unlikely() micro to the unlikely conditions in the macvlan_handle_frame
> for slight optimization.
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Unnecessary, a goto is equivalent to unlikely
