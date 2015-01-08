From: Mathieu Rohon <mathieu.rohon@gmail.com>
Subject: bridge-utils : bridge fdb replace undocumented
Date: Thu, 8 Jan 2015 13:52:01 +0100
Message-ID: <CAAfiWQqCv9=nFRNuxHPb+hRVbNywiEN_bQJHaxXc29hka0iUaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:58639 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754530AbbAHMwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 07:52:03 -0500
Received: by mail-qa0-f53.google.com with SMTP id j7so7062993qaq.12
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 04:52:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

the command :
#bridge fdb replace

can be useful to replace a learned Mac address by a static one. We'd
like to use this command to solve an openstack bug :
https://bugs.launchpad.net/neutron/+bug/1367999

However it is not documented in the manpage of bridge-utilis version 1.5.9.

Also, I don't know what is the minimum version to have this features.

regards,
Mathieu
