From: Laurent Chavey <chavey@google.com>
Subject: Re: [PATCH 3/8] ethoc: enable interrupts after napi_complete
Date: Wed, 24 Nov 2010 11:33:08 -0800
Message-ID: <AANLkTikouH+h7BPhSHY3d_4bZ=QTtiMC3ioJnS6cNe_u@mail.gmail.com>
References: <1290606058-26703-1-git-send-email-jonas@southpole.se>
 <1290606058-26703-4-git-send-email-jonas@southpole.se> <AANLkTim=Y6NGk8MSq=hJTrBKaYuk4SJ_7wA=f+UBy3d0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Adam Edvardsson <adam.edvardsson@orsoc.se>
To: Jonas Bonn <jonas@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:26599 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302Ab0KXTdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 14:33:52 -0500
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id oAOJXoB2001296
	for <netdev@vger.kernel.org>; Wed, 24 Nov 2010 11:33:50 -0800
Received: from yxh35 (yxh35.prod.google.com [10.190.2.227])
	by wpaz33.hot.corp.google.com with ESMTP id oAOJXn2M008136
	for <netdev@vger.kernel.org>; Wed, 24 Nov 2010 11:33:49 -0800
Received: by yxh35 with SMTP id 35so66514yxh.41
        for <netdev@vger.kernel.org>; Wed, 24 Nov 2010 11:33:49 -0800 (PST)
In-Reply-To: <AANLkTim=Y6NGk8MSq=hJTrBKaYuk4SJ_7wA=f+UBy3d0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

actually my previous comments are not correct.
the check for work_done < budget will
only cause an extra call with work_done == 0
if no more work is done.
so that will work.

--
--------------------------------------------------------------------------------
