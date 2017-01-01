From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH v2 3/6] qedi: Add QLogic FastLinQ offload iSCSI driver framework.
Date: Sun, 1 Jan 2017 14:28:47 +0200
Message-ID: <CAJ3xEMjWK_6dhhmXHcgXj0jV6QP=4h+vXE4JJgu9n2d+zQZ0jg@mail.gmail.com>
References: <1478588223-16183-1-git-send-email-manish.rangankar@cavium.com> <1478588223-16183-4-git-send-email-manish.rangankar@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>,
        lduncan@suse.com, Chris Leech <cleech@redhat.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Yuval.Mintz@cavium.com
To: Manish Rangankar <manish.rangankar@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36524 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754980AbdAAM2t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 07:28:49 -0500
Received: by mail-oi0-f66.google.com with SMTP id u15so63536976oie.3
        for <netdev@vger.kernel.org>; Sun, 01 Jan 2017 04:28:49 -0800 (PST)
In-Reply-To: <1478588223-16183-4-git-send-email-manish.rangankar@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Seems you forgot to add roper dep on UIO

ERROR: "uio_unregister_device" [drivers/scsi/qedi/qedi.ko] undefined!
ERROR: "uio_event_notify" [drivers/scsi/qedi/qedi.ko] undefined!
ERROR: "__uio_register_device" [drivers/scsi/qedi/qedi.ko] undefined!

BTW, what is the usage you do with that??

Or.


Wh
