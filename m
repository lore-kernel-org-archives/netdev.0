From: Josh Boyer <jwboyer@fedoraproject.org>
Subject: commit 957f094f221f for 3.19.y stable
Date: Wed, 25 Mar 2015 13:21:33 -0400
Message-ID: <CA+5PVA7da0VBi0Cho1m6UoKh0-hqiVYgJbmTU28FnXznkgk7Tg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:34169 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753004AbbCYRVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 13:21:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

We had a report[1] that 3.19 broke the Juniper VPN.  Commit
957f094f221f (tun: return proper error code from tun_do_read) was
identified as the fix and tested successfully on top of 3.19.2.  I
noticed it wasn't included in your latest set of patches for the
stable trees.  I don't believe it's something you have queued in your
stable mbox on patchwork either.  Is this something that should be
queued up for stable?

josh

[1] http://bugzilla.redhat.com/1204512
