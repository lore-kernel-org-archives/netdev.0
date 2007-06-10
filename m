From: "David Planella" <david.planella@googlemail.com>
Subject: The future of the TI ACX wireless driver
Date: Sun, 10 Jun 2007 16:35:23 +0200
Message-ID: <1d9d9b240706100735k374b5800ie64370e1e9bff1ef@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: acx100-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.245]:2866 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362AbXFJOfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jun 2007 10:35:25 -0400
Received: by an-out-0708.google.com with SMTP id d31so329925and
        for <netdev@vger.kernel.org>; Sun, 10 Jun 2007 07:35:24 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I just wanted to mention that I have updated the ACX driver's wiki in
order to at least keep up with the current state of things regarding
the driver and the kernel.

I've rearranged the contents and added some information to the main
page at http://acx100.sourceforge.net/wiki/Main_Page. In case there
are any active or inactive developers reading this, please also have a
look at the new
http://acx100.sourceforge.net/wiki/Main_Page#Development and
http://acx100.sourceforge.net/wiki/History sections (the latter one
being still pretty much under construction), and feel free to comment,
correct or add to the information shown there.

Regarding the current state of the driver, from what I could gather
from the mailing list posts scattered through netdev, acx100-devel and
acx-users and probably other places, there are three current versions
of the driver:

* "Plain" driver, which uses a homegrown wireless stack and does not
support WPA.
The last release (0.3.36) [1] was made for this flavour of the driver,
which is the one shipped with distributions such as Ubuntu. Andreas
Mohr said that after this release he'd concentrate on the softmac
version.

* Softmac driver, which uses the in-kernel ieee80211softmac layer for
the common wireless functions.
The code for this driver has been in the wireless-2.6 tree (under
tiacx) for some time, and if I understand it correctly includes the
changes from the 0.3.35 version of the "plain" driver but not yet
those of the 0.3.36 version.

* Mac80211 driver, which uses the seemingly
soon-to-be-included-in-kernel mac80211 stack, available on the
wireless-dev tree (the stack, not the driver).
This release is only available here [2] and needs some work before
being included in wireless-dev, since it was released at the time when
mac80211 was still called d80211. In any case, having had a quick look
at the code, I believe that replacing the d80211.h header reference to
mac80211.h and maybe refactoring some functions might be all what is
needed for an initial compilation. Note that I haven't got any
previous driver or kernel module development experience, so I might be
wrong here. What would also be needed is to merge all changes from the
softmac and plain drivers.

I am writing this in the hope of getting some exposure and some
interest in the driver for an eventual kernel inclusion. As far as I
understand, there are only two active developers at the moment, so I
guess any help would be appreciated.

I think the natural course of action should be to first get the
mac80211 driver in shape for inclusion in the wireless-dev tree and
then continue development from there.

I (and maybe someone else) would be willing to help on this, but might
need some 'mentoring' from the developers, since as I mentioned I've
got no previous experience with linux modules or 80211. I have started
looking at the acx-d80211 code, but I cannot promise anything.

Any comments will be greatly appreciated.

Note: I'm CC'ing netdev and linux-wireless as well. I think
linux-wireless should be more appropriate, but previous posts
regarding the tiacx driver were sent to netdev.

Kind regards,
David.

[1] Announcement:
http://sourceforge.net/mailarchive/forum.php?thread_name=20070101224549.GA21249%40rhlx01.hs-esslingen.de&forum_name=acx100-users
[2] http://www.cmartin.tk/acx/acx-d80211-20060709.tar.bz2
