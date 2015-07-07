From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 6/7] hvsock: introduce Hyper-V VM Sockets feature
Date: Tue, 7 Jul 2015 11:31:12 -0700
Message-ID: <20150707113112.408b6c5d@urahara>
References: <1436194049-27829-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org, olaf@aepfle.de,
	apw@canonical.com, jasowang@redhat.com, kys@microsoft.com,
	haiyangz@microsoft.com
To: Dexuan Cui <decui@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:35533 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933143AbbGGSbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 14:31:04 -0400
Received: by pdbci14 with SMTP id ci14so130153471pdb.2
        for <netdev@vger.kernel.org>; Tue, 07 Jul 2015 11:31:03 -0700 (PDT)
In-Reply-To: <1436194049-27829-1-git-send-email-decui@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  6 Jul 2015 07:47:29 -0700
Dexuan Cui <decui@microsoft.com> wrote:

> Hyper-V VM sockets (hvsock) supplies a byte-stream based communication
> mechanism between the host and a guest. It's kind of TCP over VMBus, but
> the transportation layer (VMBus) is much simpler than IP. With Hyper-V VM
> Sockets, applications between the host and a guest can talk with each
> other directly by the traditional BSD-style socket APIs.
> 
> Hyper-V VM Sockets is only available on Windows 10 host and later. The
> patch implements the necessary support in the guest side by introducing
> a new socket address family AF_HYPERV.
> 
> Signed-off-by: Dexuan Cui <decui@microsoft.com>

Is there any chance that AF_VSOCK could be used with different transport
for VMware and Hyper-V. Better to make guest applications host independent.
