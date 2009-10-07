From: Andrew Grover <andy.grover@gmail.com>
Subject: using huge numbers of queues
Date: Wed, 7 Oct 2009 14:59:49 -0700
Message-ID: <c0a09e5c0910071459r2768f420lae87f7404dfbc054@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:51121 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754856AbZJGWA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 18:00:56 -0400
Received: by qw-out-2122.google.com with SMTP id 3so2015600qwe.37
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2009 14:59:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert,

At NetConf, you made a passing remark about wanting lots of queues,
even 1-per-socket. Have you thought further about how we would use so
many?

Thinking about this reminded me of VJ's 2006 netchannel concept, which
although not adopted, was pretty interesting. Would having 1 queue per
socket (or at least 1 per process) and hw that is able to filter
individual flows (I think the Intel 82599 can do this now for up to
128) perhaps make netchannels workable? At least this would get all
processing out of int/bh and into process context, if not userspace,
no?

Regards -- Andy
