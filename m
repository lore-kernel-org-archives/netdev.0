From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2] iplink_bond: fix parameter value matching
Date: Mon, 17 Feb 2014 11:00:03 -0800
Message-ID: <20140217110003.320dcd20@nehalam.linuxnetplumber.net>
References: <52F448AF.3060604@huawei.com>
	<20140213163159.7F73CE668E@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ding Tianhong <dingtianhong@huawei.com>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:46447 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753395AbaBQTAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 14:00:06 -0500
Received: by mail-pd0-f171.google.com with SMTP id g10so15153440pdj.16
        for <netdev@vger.kernel.org>; Mon, 17 Feb 2014 11:00:06 -0800 (PST)
In-Reply-To: <20140213163159.7F73CE668E@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Feb 2014 17:31:59 +0100 (CET)
Michal Kubecek <mkubecek@suse.cz> wrote:

> Lookup function get_index() compares argument with table entries
> only up to the length of the table entry so that if an entry
> with lower index is a substring of a later one, earlier entry is
> used even if the argument is equal to the other. For example,
> 
>   ip link set bond0 type bond xmit_hash_policy layer2+3
> 
> sets xmit_hash_policy to 0 (layer2) as this is found before
> "layer2+3" can be checked.
> 
> Use strcmp() to compare whole strings instead.
> 
> v2: look for an exact match only
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Applied
