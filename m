From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2] tc: Show classes in tree view
Date: Mon, 22 Dec 2014 17:35:54 -0800
Message-ID: <20141222173554.349bb18c@urahara>
References: <1419263518-14434-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:43034 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbaLWBgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 20:36:05 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so6909670pab.6
        for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 17:36:04 -0800 (PST)
In-Reply-To: <1419263518-14434-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Dec 2014 17:51:58 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> +	while (cls && cls->cls_parent) {
> +		cls->cls_parent->cls_right = cls;
> +		cls = cls->cls_parent;
> +	}
> +	while (cls && cls->cls_right)
> +	{

Why the sudden shift of bracketing style?
