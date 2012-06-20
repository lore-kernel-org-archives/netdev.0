From: "devendra.aaru" <devendra.aaru@gmail.com>
Subject: Q: NET/JME: pci_get_drvdata pointer return check at jme_remove
Date: Wed, 20 Jun 2012 22:50:32 +0530
Message-ID: <CAHdPZaNeW3YwaJh4RYpkz2hY5n7SO9fsN8YKroCABig7ZRsU2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:33624 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754449Ab2FTRUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 13:20:32 -0400
Received: by pbbrp8 with SMTP id rp8so876368pbb.19
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2012 10:20:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

looking at the jme_init_one error path, the context of the driver data
is set to null.

If the driver unloads , the unload _remove_one, will be called and
deferencing the pointer, leading to a oops.

so we need to have a check at before doing the netdev_priv at remove_one.

Please correct me if my understanding is wrong....

Thanks,
Devendra.
