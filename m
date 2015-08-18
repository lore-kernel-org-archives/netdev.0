From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: linux-next: unregister_netdevice: waiting for lo to become free.
 Usage count = 1
Date: Tue, 18 Aug 2015 09:27:11 -0600
Message-ID: <55D34ECF.9050909@cumulusnetworks.com>
References: <CANaxB-z52c-1jqN4fFFECpz1EaDC6B-62WyqtJqNJRiKLhyg7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrey Wagin <avagin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:33572 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752846AbbHRP1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 11:27:23 -0400
Received: by igfj19 with SMTP id j19so85726656igf.0
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 08:27:23 -0700 (PDT)
In-Reply-To: <CANaxB-z52c-1jqN4fFFECpz1EaDC6B-62WyqtJqNJRiKLhyg7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/18/15 9:24 AM, Andrey Wagin wrote:
> Hello David,
>
> CRIU tests detetect that references on net devices leak on
> 4.2.0-rc6-next-20150817. Looks like it started with
> v4.2-rc6-882-g3bfd847.

1e3136789975f03e461798149309034e5213c1b4 should have fixed it.

David
