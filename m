From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Device with variable hard header len
Date: Fri, 9 Jan 2009 00:06:26 +0300
Message-ID: <20090108201959.GA20013@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:58683 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269AbZAHVJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 16:09:04 -0500
Received: by fg-out-1718.google.com with SMTP id 19so3321316fgg.17
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2009 13:09:03 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Sorry if this a dumb question. Currently I'm programming a driver for
the devices with variable network header len. From the Linux net stack
perspective what should I do: set netdev->hard_header_len to maximum
possible header and use less space that specified there or set
netdev->needed_headroom to that value?

If that metters, I'll be implementing my own set of header_ops in any
case.

Thank you

-- 
With best wishes
Dmitry

