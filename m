From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP transmit performance regression
Date: Thu, 05 Jul 2012 16:28:49 +0200
Message-ID: <1341498529.2583.4155.camel@edumazet-glaptop>
References: <CACVXFVNM-Db=_793SVfRj+nxGtNG0pRFrwc_F9TGbU0FfES63A@mail.gmail.com>
	 <1341474192.2583.3299.camel@edumazet-glaptop>
	 <CACVXFVNxcdEYd-KmkUe9=8+x_9s-ZVuoM=FfZ=QXa7w_qRiTnw@mail.gmail.com>
	 <1341477192.2583.3415.camel@edumazet-glaptop>
	 <CACVXFVPTXB7t=zwkm+HTgDaF3bA02bzff_52S+UAr51PfpvpCg@mail.gmail.com>
	 <1341481760.2583.3579.camel@edumazet-glaptop>
	 <CACVXFVNZ=64+=w1ZapXeXq7oYz0OBbBRLuH8rNSeDHyz7zGOZw@mail.gmail.com>
	 <1341484919.2583.3688.camel@edumazet-glaptop>
	 <CACVXFVPksMd8CGZWEGBXBXB5NZCg3QOZreOLavkV-Z2pjE-M_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:34251 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191Ab2GEO2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 10:28:53 -0400
Received: by eaak11 with SMTP id k11so3269049eaa.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 07:28:52 -0700 (PDT)
In-Reply-To: <CACVXFVPksMd8CGZWEGBXBXB5NZCg3QOZreOLavkV-Z2pjE-M_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-05 at 22:01 +0800, Ming Lei wrote:

> Basically, copy path will be bypassed since hard_header_len
> has included the 'overhead' already.

Unfortunately this is not done correctly.

needed_headroom should be set to SMSC95XX_TX_OVERHEAD_CSUM
