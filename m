From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: Fix crash when dump stats from /proc with
 '-p'
Date: Mon, 20 Jul 2015 13:43:40 -0700
Message-ID: <20150720134340.6c7f8df7@urahara>
References: <1437421583-20999-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33814 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455AbbGTUng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 16:43:36 -0400
Received: by pacan13 with SMTP id an13so107601644pac.1
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 13:43:35 -0700 (PDT)
In-Reply-To: <1437421583-20999-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Jul 2015 22:46:23 +0300
Vadim Kochan <vadim4j@gmail.com> wrote:

> +		if (s->name)
> +			free(s->name);

Please don't add unnecessary conditional.
  free(NULL) is defined to do nothing.
