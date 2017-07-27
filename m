From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] netns: more input validation
Date: Thu, 27 Jul 2017 11:26:05 -0700
Message-ID: <20170727112605.58d9c7a2@xeon-e3>
References: <20170725133031.7735-1-mcroce@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matteo Croce <mcroce@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36594 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751441AbdG0S0H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 14:26:07 -0400
Received: by mail-pf0-f170.google.com with SMTP id z129so47083758pfb.3
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 11:26:07 -0700 (PDT)
In-Reply-To: <20170725133031.7735-1-mcroce@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Jul 2017 15:30:31 +0200
Matteo Croce <mcroce@redhat.com> wrote:

> ip netns accepts invalid input as namespace name like an empty string or a
> string longer than the maximum file name length.
> Check that the netns name is not empty and less than or equal to NAME_MAX.
> 
> Signed-off-by: Matteo Croce <mcroce@redhat.com>

Sure, applied.
