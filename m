From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] VSOCK: add tools/vsock/vsock_diag_test
Date: Tue, 03 Oct 2017 21:48:05 -0700 (PDT)
Message-ID: <20171003.214805.176732000485014040.davem@davemloft.net>
References: <20171003153943.23159-1-stefanha@redhat.com>
        <20171003153943.23159-6-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhansen@vmware.com, decui@microsoft.com
To: stefanha@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33286 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750871AbdJDEsG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 00:48:06 -0400
In-Reply-To: <20171003153943.23159-6-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Hajnoczi <stefanha@redhat.com>
Date: Tue,  3 Oct 2017 11:39:43 -0400

>  MAINTAINERS                   |   1 +
>  tools/vsock/Makefile          |   9 +
>  tools/vsock/control.h         |  13 +
>  tools/vsock/timeout.h         |  14 +
>  tools/vsock/control.c         | 219 ++++++++++++++
>  tools/vsock/timeout.c         |  64 ++++
>  tools/vsock/vsock_diag_test.c | 681 ++++++++++++++++++++++++++++++++++++++++++
>  tools/vsock/.gitignore        |   2 +

Please don't create you own "special" directory for tests.

Tests belong under tools/testing/selftests/

If you put your tests in the proper place, and structure them properly (especially
the Makefile rules), they will automatically be run by various automated build
and test frameworks.
