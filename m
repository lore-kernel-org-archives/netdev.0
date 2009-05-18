From: Raju Srivastava <raju.s.linux@gmail.com>
Subject: virtio-net zero-copy
Date: Mon, 18 May 2009 21:19:47 +0800
Message-ID: <bd8f29360905180619g3ccee719m268f57e63a88fd4f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, kvm@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f224.google.com ([209.85.219.224]:50216 "EHLO
	mail-ew0-f224.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950AbZERNTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 09:19:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings,

Could someone let me know if current virtio-net supports zero-copy? I
see some discussion here:
http://thread.gmane.org/gmane.comp.emulators.kvm.devel/28061/
(copyless virtio net thoughts) and it looks like the copyless
virtio-net is not supported by KVM yet. If this is true, then is there
any plan to add the zero copy to the virtio-net?

I use KVM in 10G network environment and found the CPU usage is
saturated when network traffic becomes heavy. The native Linux under
the same load only consumes less than 10% CPU.

Thanks in advance,
Raju
