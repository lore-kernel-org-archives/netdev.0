From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: circular locking dependency splat due to f9eb8aea2a1e
Date: Wed, 8 Jun 2016 14:31:36 -0600
Message-ID: <70835825-c395-7a1a-90e1-fb0e3542adbf@cumulusnetworks.com>
References: <471b265b-d938-fd3c-7de6-91cc232b4e2b@cumulusnetworks.com>
 <CANn89iLquP-_fsFrSOUqxtg3YCYNuXgqO+TCYMcxc8foChB8jA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36381 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161793AbcFHUb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 16:31:28 -0400
Received: by mail-pa0-f46.google.com with SMTP id b5so5519854pas.3
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 13:31:28 -0700 (PDT)
In-Reply-To: <CANn89iLquP-_fsFrSOUqxtg3YCYNuXgqO+TCYMcxc8foChB8jA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/8/16 2:30 PM, Eric Dumazet wrote:
>
> It looks VRF was already lacking annotation for busylock then ?

I sent a patch adding IFF_NO_QUEUE flag
