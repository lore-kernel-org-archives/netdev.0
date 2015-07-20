From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next iproute2] support batching of ip route get
 commands
Date: Mon, 20 Jul 2015 14:56:09 -0700
Message-ID: <20150720145609.77a0d85c@urahara>
References: <1437005196-8914-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:36466 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756835AbbGTVz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 17:55:59 -0400
Received: by pdjr16 with SMTP id r16so109701475pdj.3
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 14:55:58 -0700 (PDT)
In-Reply-To: <1437005196-8914-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Jul 2015 17:06:36 -0700
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch replaces exits with returns in
> ip route get command handling. This allows batching
> of ip route get commands.
> 
> $cat route_get_batch.txt
> route get 10.0.14.2
> route get 12.0.14.2
> route get 10.0.14.4
> 
> $ip -batch route_get_batch.txt
> local 10.0.14.2 dev lo  src 10.0.14.2
>     cache <local>
> 12.0.14.2 via 192.168.0.2 dev eth0  src 192.168.0.15
>     cache
> 10.0.14.4 dev dummy0  src 10.0.14.2
>     cache
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Looks good and simple, applied.
