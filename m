From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH 5/5] VSOCK: add tools/vsock/vsock_diag_test
Date: Wed, 4 Oct 2017 11:05:33 -0400
Message-ID: <20171004150533.GD3840@stefanha-x1.localdomain>
References: <20171003153943.23159-1-stefanha@redhat.com>
 <20171003153943.23159-6-stefanha@redhat.com>
 <20171003.214805.176732000485014040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhansen@vmware.com, decui@microsoft.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51402 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752599AbdJDPFm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Oct 2017 11:05:42 -0400
Content-Disposition: inline
In-Reply-To: <20171003.214805.176732000485014040.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 03, 2017 at 09:48:05PM -0700, David Miller wrote:
> From: Stefan Hajnoczi <stefanha@redhat.com>
> Date: Tue,  3 Oct 2017 11:39:43 -0400
> 
> >  MAINTAINERS                   |   1 +
> >  tools/vsock/Makefile          |   9 +
> >  tools/vsock/control.h         |  13 +
> >  tools/vsock/timeout.h         |  14 +
> >  tools/vsock/control.c         | 219 ++++++++++++++
> >  tools/vsock/timeout.c         |  64 ++++
> >  tools/vsock/vsock_diag_test.c | 681 ++++++++++++++++++++++++++++++++++++++++++
> >  tools/vsock/.gitignore        |   2 +
> 
> Please don't create you own "special" directory for tests.
> 
> Tests belong under tools/testing/selftests/
> 
> If you put your tests in the proper place, and structure them properly (especially
> the Makefile rules), they will automatically be run by various automated build
> and test frameworks.

Cool, thanks for the hint.  I wasn't aware of that.

Will fix in v2.

Stefan
