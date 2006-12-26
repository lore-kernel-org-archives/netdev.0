From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/5] myri10ge: match number of save_state and restore
Date: Tue, 26 Dec 2006 16:28:40 -0500
Message-ID: <45919408.1050608@garzik.org>
References: <45867228.1090406@myri.com> <45867258.3050304@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41441 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932803AbWLZV2m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Dec 2006 16:28:42 -0500
To: Brice Goglin <brice@myri.com>
In-Reply-To: <45867258.3050304@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> Since pci_save_state() pushes MSI and PCIe states on a kind of stack,
> myri10ge saving the state in advance for parity recovery will push the
> state again on the stack on suspend. This leads to some memory leak.
> We add a couple additional calls to save_state and restore_state so
> that we don't leak anymore.
> 
> For the future, we are thinking of a better way to recover from parity
> error without using pci_save_state().
> 
> Signed-off-by: Brice Goglin <brice@myri.com>

applied 1-5


