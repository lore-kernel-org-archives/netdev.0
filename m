From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] net: don't call strlen() on the user buffer in
 packet_bind_spkt()
Date: Wed, 01 Mar 2017 07:48:09 -0800
Message-ID: <1488383289.9415.286.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170301115720.99985-1-glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alexander Potapenko <glider@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36299 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752652AbdCAPyl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 10:54:41 -0500
In-Reply-To: <20170301115720.99985-1-glider@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-03-01 at 12:57 +0100, Alexander Potapenko wrote:
> KMSAN (KernelMemorySanitizer, a new error detection tool) reports use of
> uninitialized memory in packet_bind_spkt():
...
> Signed-off-by: Alexander Potapenko <glider@google.com>
> ---
> Changes since v3:
>  - addressed comments by Eric Dumazet (avoid using constants,
>    use memcpy() instead of strncpy())
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
