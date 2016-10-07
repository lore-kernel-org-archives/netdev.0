From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: Reversion of "xen-netback: create a debugfs node for hash
 information"
Date: Fri, 7 Oct 2016 09:50:04 +0000
Message-ID: <cbedcf0845fb449892e415e2a1c69a40@AMSPEX02CL03.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Wei Liu <wei.liu2@citrix.com>
To: "David Miller (davem@davemloft.net)" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:44849 "EHLO
        SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751549AbcJGJuI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 05:50:08 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

  I notice that you have made the above reversion of commit c0c64c15 (debugfs node) due to a build failure, despite the failure being caused by commit 0364a882 (switch to threaded irq) which was made subsequently. I assume you want me to re-spin a new patch for the debugfs node to fix the build problem?

  Cheers,

    Paul
