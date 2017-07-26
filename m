From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] bridge: Assume master at FDB modification
Date: Wed, 26 Jul 2017 09:08:20 -0700
Message-ID: <20170726090820.0252da7e@xeon-e3>
References: <1501083394-26180-1-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        nikolay@cumulusnetworks.com, vivien.didelot@savoirfairelinux.com,
        mlxsw@mellanox.com
To: Arkadi Sharshevsky <arkadis@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:33750 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751726AbdGZQIX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 12:08:23 -0400
Received: by mail-pg0-f46.google.com with SMTP id b8so9536615pgn.0
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 09:08:23 -0700 (PDT)
In-Reply-To: <1501083394-26180-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Jul 2017 18:36:34 +0300
Arkadi Sharshevsky <arkadis@mellanox.com> wrote:

> According to the man page the master flag should be the default, yet, the
> current code assumes otherwise.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>

Agree that the documentation and code don't match.
But your change could break users with existing scripts by changing behavior.

It would be safer to change the man page not the code.
