From: Richard Cochran <richardcochran@gmail.com>
Subject: cpsw_ale clobbers learned addresses?
Date: Wed, 13 May 2015 21:38:16 +0200
Message-ID: <20150513193816.GA11130@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mugunthanvnm@ti.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:33668 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934379AbbEMTiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 15:38:21 -0400
Received: by wgin8 with SMTP id n8so54045359wgi.0
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 12:38:20 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It appears to me that cpsw_ale.c will possibly clobber addresses
learned by the switch.   When adding a new entry, the code reads the
table until it finds an empty entry.  Then, it writes the new value to
that same index.  However, nothing prevents the switch from using that
same index between the read and the write.

Or am I missing something?

Thanks,
Richard
