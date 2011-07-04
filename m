From: Adam Katz <adamkatz0@gmail.com>
Subject: libpcap and tc filters
Date: Mon, 4 Jul 2011 10:38:35 +0300
Message-ID: <CAA0qwj6fWJFVCDW9M9jZhvQnSTy=Pnyp0AhWFYT8FOiroq7C=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:64318 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753755Ab1GDHig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 03:38:36 -0400
Received: by iyb12 with SMTP id 12so4248152iyb.19
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 00:38:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Everyone

I'm sorry for littering the mailing list with this question, but no
other place could help me..

I'm attempting to use tc to shape traffic sent using libpcap, I'm
doing this for a research project. I have a classful scheduler with
several classes, to this scheduler I attach a few filters based on
destination tcp ports.

My problem is this: When sending packets using a normal userland
socket, the filters work and I see the appropriate traffic entering
the right class. BUT when sending packets with libpcap, all packets
end up in the scheduler's default band as if the filters simply refuse
to work.

Can anyone suggest a solution?
