From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Re: [1/1] Kevent subsystem.
Date: Thu, 22 Jun 2006 21:53:38 +0200
Message-ID: <7e63f56c0606221253k7e3d28eejc75bf1be4304c389@mail.gmail.com>
References: <20060622171436.GA26161@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:37286 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932636AbWFVTxk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 15:53:40 -0400
Received: by nf-out-0910.google.com with SMTP id o60so313290nfa
        for <netdev@vger.kernel.org>; Thu, 22 Jun 2006 12:53:38 -0700 (PDT)
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
In-Reply-To: <20060622171436.GA26161@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy,

On 6/22/06, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> Kevent subsystem incorporates several AIO/kqueue design notes and ideas.
> Kevent can be used both for edge and level notifications. It supports
> socket notifications, network AIO (aio_send(), aio_recv() and
> aio_sendfile()), inode notifications (create/remove),
> generic poll()/select() notifications and timer notifications.

Great job!
Smooth integration with userland asynch POSIX frameworks
(e.g. ACE POSIX_Proactor) may require syscalls (or their emulation)
with POSIX interface:

 * POSIX_API
 * aio_read
 * aio_write
 * aio_suspend
 * aio_error
 * aio_return
 * aio_cancel

where aio_suspend is very important.
-- 
Sincerely,
------------------------------------------------------------------
Robert Iakobashvili, coroberti at gmail dot com
Navigare necesse est, vivere non est necesse.
------------------------------------------------------------------
