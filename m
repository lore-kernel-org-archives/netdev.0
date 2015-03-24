From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] lib utils: fix family during af_bit_len
 calculation
Date: Tue, 24 Mar 2015 15:05:00 -0700
Message-ID: <20150324150500.6159e407@urahara>
References: <1426645109-3411-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vadim4j@gmail.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:33457 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbbCXWE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 18:04:57 -0400
Received: by pdnc3 with SMTP id c3so6704319pdn.0
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 15:04:57 -0700 (PDT)
In-Reply-To: <1426645109-3411-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Mar 2015 19:18:28 -0700
roopa@cumulusnetworks.com wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> commit f3a2ddc124e0 ("lib utils: Use helpers to get AF bit/byte len")
> used a wrong family or family of zero in the default case
> during af_bit_len calculation causing ip route commands to
> fail with below error
> 
> Error: an inet prefix is expected rather than "10.0.2.14/24".
> 
> Reported-by: Sven-Haegar Koch <haegar@sdinet.de>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied, thanks everybody
