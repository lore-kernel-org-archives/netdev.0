From: Javier Domingo <javierdo1@gmail.com>
Subject: Information about napi_struct and net_device
Date: Sat, 27 Oct 2012 18:18:39 +0200
Message-ID: <CALZVap=ybdWdK22LHsfSRu+TVCJnvL95KeChtCdX8DE-C=1gAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:46168 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756488Ab2J0QTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2012 12:19:00 -0400
Received: by mail-vc0-f174.google.com with SMTP id fk26so4034428vcb.19
        for <netdev@vger.kernel.org>; Sat, 27 Oct 2012 09:18:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am updating a kernel patch from 2.6.23-rc7 to v3.6, using git
facilities, and I have found that there have been lots of changes in
networking. Now the drivers are all by vendor, and more important,
net_device is not used always, as napi_struct took its place.

I have asked in #kernel but no one answered me, so I subscribed here.
Is there any place I can read about how is it now designed the use of
napi_struct and net_device? I have found a presentation[1] about how
networking was changing etc, and I wondered if there is anything more
precise about how it is actually implemented.

I understand a little why napi_struct, but don't really know much
about the change,

Hope someone can help me,

Javier Domingo


[1]: http://vger.kernel.org/~davem/davem_nyc09.pdf
