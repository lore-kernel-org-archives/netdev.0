From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: A generic kernel compatibilty code
Date: Fri, 20 Nov 2009 12:45:51 -0800
Message-ID: <43e72e890911201245r4de5b039hb2dd5011dabf2399@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f178.google.com ([209.85.223.178]:64591 "EHLO
	mail-iw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752989AbZKTUqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 15:46:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Everyone and their mother reinvents the wheel when it comes to
backporting kernel modules. It a painful job and it seems to me an
alternative is possible. If we can write generic compatibilty code for
a new routine introduced on the next kernel how about just merging it
to the kernel under some generic compat module. This would be
completey ignored by everyone using the stable kernel but can be
copied by anyone doing backport work.

So I'm thinking something as simple as a generic compat/comat.ko with
compat-2.6.32.[ch] files.

We've already backported everything needed for wireless drivers under
compat-wireless under this format down to even 2.6.25. I volunteer to
be the sucker for this if this is reasonable and given the shot to try
it.

If you would like a better idea of what I mean please check out this
git tree and check out the files under compat/*.[ch]

git://git.kernel.org/pub/scm/linux/kernel/git/mcgrof/compat-wireless-2.6.git

Things which *cannot* be backported through new defines or exported
symbols are handled manually through patches (check compat/patches/)
but no need for something like that upstream it seems.

Please let me know what you think.

 Luis
