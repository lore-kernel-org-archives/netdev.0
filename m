From: Ed Swierk <eswierk@aristanetworks.com>
Subject: Re: [PATCH v2] net/macvtap: fix reference counting
Date: Fri, 12 Feb 2010 12:58:08 -0800
Message-ID: <9ae48b021002121258l6f0849c6w51886bd2b2893c1c@mail.gmail.com>
References: <201001271104.20607.arnd@arndb.de> <4B72F67F.1040008@trash.net>
	 <201002111645.02770.arnd@arndb.de> <201002111655.40349.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Patrick McHardy <kaber@trash.net>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:8355 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753613Ab0BLU6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 15:58:10 -0500
Received: by ey-out-2122.google.com with SMTP id d26so714757eyd.19
        for <netdev@vger.kernel.org>; Fri, 12 Feb 2010 12:58:08 -0800 (PST)
In-Reply-To: <201002111655.40349.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 11, 2010 at 7:55 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> The RCU usage in the original code was broken because
> there are cases where we possibly sleep with rcu_read_lock
> held. As a fix, change the macvtap_file_get_queue to
> get a reference on the socket and the netdev instead of
> taking the full rcu_read_lock.
>
> Also, change macvtap_file_get_queue failure case to
> not require a subsequent macvtap_file_put_queue, as
> pointed out by Ed Swierk.

Works for me. Thanks.

Acked-by: Ed Swierk <eswierk@aristanetworks.com>
