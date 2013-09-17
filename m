From: Vincent Li <vincent.mc.li@gmail.com>
Subject: add ip to interface as primary ip address, not secondary ip when
 there is alreadly primary ip?
Date: Tue, 17 Sep 2013 15:31:21 -0700
Message-ID: <CAK3+h2zPYYLaVs-WhHFaDhOsnLBB7m8vDvkTj5a16FUJ02i4KA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:51983 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288Ab3IQWbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 18:31:22 -0400
Received: by mail-ob0-f178.google.com with SMTP id uy5so6596427obc.9
        for <netdev@vger.kernel.org>; Tue, 17 Sep 2013 15:31:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

we need to add  more than one ip address to one interface, but want to
be able to specify which ip address to be primary and which to be
secondary (be deterministic) , what we have found out is that the
first ip address added to the interface will be always the primary ip
address, the primary or secondary is depending on which ip get added
to the interface first.

we could also delete an existing primary ip address, then the
secondary ip will be promoted to primary.

ideally though, we would like to have the capability in
kernel/userspace  to specify a flag or something to add any ip as
primary even if there is already existing primary ip address (could
downgrade the existing primary to secondary ip). does this make sense
?

Vincent
