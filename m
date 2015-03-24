From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] fix ip -force -batch to continue on errors
Date: Tue, 24 Mar 2015 15:00:21 -0700
Message-ID: <20150324150021.1cf3a756@urahara>
References: <1426645592-4002-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, haegar@sdinet.de
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:34864 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842AbbCXWAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 18:00:20 -0400
Received: by pdbop1 with SMTP id op1so6454814pdb.2
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 15:00:19 -0700 (PDT)
In-Reply-To: <1426645592-4002-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Mar 2015 19:26:32 -0700
roopa@cumulusnetworks.com wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch replaces exits with returns in several
> iproute2 commands. This fixes `ip -batch -force`
> to not exit but continue on errors.
> 
> $cat c.txt
> route del 1.2.3.0/24 dev eth0
> route del 1.2.4.0/24 dev eth0
> route del 1.2.5.0/24 dev eth0
> route add 1.2.3.0/24 dev eth0
> 
> $ip -force -batch c.txt
> RTNETLINK answers: No such process
> Command failed c.txt:2
> RTNETLINK answers: No such process
> Command failed c.txt:3
> 
> Reported-by: Sven-Haegar Koch <haegar@sdinet.de>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied thanks
