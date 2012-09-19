From: byungho an <bh74an@gmail.com>
Subject: Regarding ethernet directory between IP and SoC chip vendor.
Date: Wed, 19 Sep 2012 21:39:47 +0900
Message-ID: <CAG4h5ywgCS0n8t70uUNmSOVhKBPkOLeVLaO+D4tYfUT2qN7qTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, peppe.cavallaro@st.com, deepak.silki@st.com,
	francesco.virlinzi@st.com, jeffrey.t.kirsher@intel.com,
	eilong@broadcom.com, alexander.h.duyck@intel.com,
	bhutchings@solarflare.com, linville@tuxdriver.com,
	wey-ty.w.guy@intel.com, coelho@ti.com, e.wahlig@samsung.com,
	aditya.ps@samsung.com, ihlee215@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:49660 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500Ab2ISMjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 08:39:48 -0400
Received: by oago6 with SMTP id o6so968940oag.19
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 05:39:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I have one suggestion for ethernet dir.
Currently It is well-defined and good for management.

But if IP vendor is different from SoC vender, It is a bit confusing
to guess dir name.
For example, stmmac is using Synopsys dwmac.
In this case, if another SoC vendors try to use Synopsys IP, they
sould make their own dir under the their name? Even the IP is same...

If there is common dir of IP vendor, It would be more clear.
If that, other SoC vendors that try to use the IP can make their own
directory and drivers intuitionally.

What do you think about it?
I want to exchange opinion and find a resonable and rational way.

Thank you.
Andy
