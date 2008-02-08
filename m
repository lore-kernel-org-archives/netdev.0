From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH] [NETNS] Remove unused member (dst_net) of dst_ops.
Date: Fri, 8 Feb 2008 13:24:30 +0200
Message-ID: <eb3ff54b0802080324i4c7df923y3476faa34392279a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_14270_22946956.1202469870864"
To: "David Miller" <davem@davemloft.net>, den@openvz.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:51875 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758825AbYBHLYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 06:24:32 -0500
Received: by fg-out-1718.google.com with SMTP id e21so2880464fga.17
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2008 03:24:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_14270_22946956.1202469870864
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
  This patches removes dst_net member (a pointer to struct net)
  of dst_ops (/include/net/dst.h).
	
  Current network namespace implementation does not use it at all.

Denis - any comments ?
	

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_14270_22946956.1202469870864
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fcen3p6k0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L2RzdC5oIGIvaW5jbHVkZS9uZXQvZHN0LmgKaW5kZXgg
ZTNhYzdkMC4uYWQwNjYyMiAxMDA2NDQKLS0tIGEvaW5jbHVkZS9uZXQvZHN0LmgKKysrIGIvaW5j
bHVkZS9uZXQvZHN0LmgKQEAgLTEwMiw3ICsxMDIsNiBAQCBzdHJ1Y3QgZHN0X29wcwogCiAJYXRv
bWljX3QJCWVudHJpZXM7CiAJc3RydWN0IGttZW1fY2FjaGUgCQkqa21lbV9jYWNoZXA7Ci0Jc3Ry
dWN0IG5ldCAgICAgICAgICAgICAgKmRzdF9uZXQ7CiB9OwogCiAjaWZkZWYgX19LRVJORUxfXwo=

------=_Part_14270_22946956.1202469870864--
